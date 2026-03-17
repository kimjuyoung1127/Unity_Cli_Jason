[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,
    [Parameter(Mandatory = $true)]
    [string]$ExecuteMethod,
    [string]$UnityExePath = "C:\Program Files\Unity\Hub\Editor\6000.0.64f1\Editor\Unity.exe",
    [string]$LogFile,
    [string]$SuccessPattern,
    [int]$MaxAttempts = 2,
    [switch]$AllowProjectAlreadyOpen,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$AdditionalUnityArgs
)

$ErrorActionPreference = "Stop"
$PSNativeCommandArgumentPassing = "Standard"
$PSNativeCommandUseErrorActionPreference = $false

function Resolve-NormalizedPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    return [IO.Path]::GetFullPath($Path).TrimEnd('\').ToLowerInvariant()
}

function Get-DefaultLogFile {
    param([string]$ResolvedProjectPath)

    $logDirectory = Join-Path $ResolvedProjectPath "Temp"
    if (!(Test-Path $logDirectory)) {
        New-Item -ItemType Directory -Path $logDirectory | Out-Null
    }

    return Join-Path $logDirectory "unity-cli-batch.log"
}

function Test-ProjectAlreadyOpen {
    param([Parameter(Mandatory = $true)][string]$ResolvedProjectPath)

    $normalizedProjectPath = Resolve-NormalizedPath -Path $ResolvedProjectPath
    $unityProcesses = Get-CimInstance Win32_Process | Where-Object { $_.Name -eq "Unity.exe" }
    $matchingProcesses = @()

    foreach ($process in $unityProcesses) {
        if ([string]::IsNullOrWhiteSpace($process.CommandLine)) {
            continue
        }

        $normalizedCommandLine = $process.CommandLine.ToLowerInvariant().Replace('/', '\')
        if ($normalizedCommandLine -like "*$($normalizedProjectPath.Replace('/', '\'))*") {
            $matchingProcesses += $process
        }
    }

    return $matchingProcesses
}

function Test-CompileOnlyLog {
    param([string]$LogText)

    if ([string]::IsNullOrWhiteSpace($LogText)) {
        return $false
    }

    $hasCompileMarker =
        $LogText -match "Requested script compilation because" -or
        $LogText -match "script compilation time:" -or
        $LogText -match "Assembly Definition File\(s\) changed" -or
        $LogText -match "Assetdatabase observed changes in script compilation related files"

    $hasExecuteMarker =
        $LogText -match [regex]::Escape($ExecuteMethod) -or
        $LogText -match "Build Finished, Result: Success" -or
        $LogText -match "Batchmode quit successfully invoked" -or
        $LogText -match "Exiting batchmode successfully now!"

    return $hasCompileMarker -and -not $hasExecuteMarker
}

function Invoke-BatchAttempt {
    param(
        [Parameter(Mandatory = $true)][int]$AttemptNumber,
        [Parameter(Mandatory = $true)][string]$ResolvedProjectPath,
        [Parameter(Mandatory = $true)][string]$ResolvedUnityExePath,
        [Parameter(Mandatory = $true)][string]$AttemptLogFile
    )

    if (Test-Path $AttemptLogFile) {
        Remove-Item $AttemptLogFile -Force
    }

    $unityArgs = @(
        "-batchmode",
        "-quit",
        "-projectPath", $ResolvedProjectPath,
        "-logFile", $AttemptLogFile,
        "-executeMethod", $ExecuteMethod
    ) + $AdditionalUnityArgs

    & $ResolvedUnityExePath @unityArgs
    $exitCode = $LASTEXITCODE
    $logText = if (Test-Path $AttemptLogFile) { Get-Content $AttemptLogFile -Raw } else { "" }

    [pscustomobject]@{
        Attempt = $AttemptNumber
        ExitCode = $exitCode
        LogFile = $AttemptLogFile
        LogText = $logText
    }
}

if (!(Test-Path $UnityExePath)) {
    throw "Unity executable was not found at '$UnityExePath'."
}

if (!(Test-Path $ProjectPath)) {
    throw "Project path '$ProjectPath' does not exist."
}

$resolvedProjectPath = Resolve-NormalizedPath -Path $ProjectPath
$resolvedUnityExePath = [IO.Path]::GetFullPath($UnityExePath)
$resolvedLogFile = if ([string]::IsNullOrWhiteSpace($LogFile)) {
    Get-DefaultLogFile -ResolvedProjectPath $resolvedProjectPath
} else {
    [IO.Path]::GetFullPath($LogFile)
}

if (!$AllowProjectAlreadyOpen) {
    $lockingProcesses = Test-ProjectAlreadyOpen -ResolvedProjectPath $resolvedProjectPath
    if ($lockingProcesses.Count -gt 0) {
        $processSummary = $lockingProcesses | ForEach-Object {
            "PID=$($_.ProcessId) CMD=$($_.CommandLine)"
        }
        throw "The target Unity project is already open in another Unity instance.`n$($processSummary -join [Environment]::NewLine)"
    }
}

$lastResult = $null
for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
    $attemptLogFile = [IO.Path]::ChangeExtension($resolvedLogFile, ".attempt$attempt.log")
    $lastResult = Invoke-BatchAttempt `
        -AttemptNumber $attempt `
        -ResolvedProjectPath $resolvedProjectPath `
        -ResolvedUnityExePath $resolvedUnityExePath `
        -AttemptLogFile $attemptLogFile

    if ($lastResult.ExitCode -ne 0) {
        $logTail = ($lastResult.LogText -split "`r?`n" | Select-Object -Last 60) -join [Environment]::NewLine
        throw "Unity batch execution failed on attempt $attempt with exit code $($lastResult.ExitCode).`nLog: $attemptLogFile`n$logTail"
    }

    if ([string]::IsNullOrWhiteSpace($SuccessPattern)) {
        "Unity batch method completed on attempt $attempt."
        "Log: $attemptLogFile"
        exit 0
    }

    if ($lastResult.LogText -match $SuccessPattern) {
        "Unity batch method completed on attempt $attempt."
        "Log: $attemptLogFile"
        exit 0
    }

    if ($attempt -lt $MaxAttempts -and (Test-CompileOnlyLog -LogText $lastResult.LogText)) {
        "Detected a compile-only batch pass on attempt $attempt. Retrying..."
        continue
    }

    $logTail = ($lastResult.LogText -split "`r?`n" | Select-Object -Last 60) -join [Environment]::NewLine
    throw "Unity batch method finished without matching success pattern '$SuccessPattern'.`nLog: $attemptLogFile`n$logTail"
}

throw "Unity batch method failed after $MaxAttempts attempts."
