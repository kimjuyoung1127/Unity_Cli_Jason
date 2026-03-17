[CmdletBinding()]
param(
    [Alias("ProjectPath")]
    [string]$CliProjectPath,
    [Parameter(ValueFromRemainingArguments = $true)]
    [Alias("CommandArgs")]
    [string[]]$CliCommandArgs,
    [Alias("RetryCount")]
    [int]$CliRetryCount = 0,
    [Alias("RetryDelaySeconds")]
    [int]$CliRetryDelaySeconds = 2,
    [Alias("ReadyTimeoutSeconds")]
    [int]$CliReadyTimeoutSeconds = 60,
    [Alias("WaitForReadyBefore")]
    [switch]$CliWaitForReadyBefore,
    [Alias("WaitForReadyAfter")]
    [switch]$CliWaitForReadyAfter
)

$ErrorActionPreference = "Stop"
$PSNativeCommandArgumentPassing = "Standard"
$PSNativeCommandUseErrorActionPreference = $false

function Get-UnityCliProjectArgs {
    param([string]$ResolvedProjectPath)

    if ([string]::IsNullOrWhiteSpace($ResolvedProjectPath)) {
        return @()
    }

    return @("--project", $ResolvedProjectPath)
}

function Get-UnityCliState {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return "unknown"
    }

    if ($Text -match "ready") {
        return "ready"
    }

    if ($Text -match "no Unity instance found") {
        return "no_instance"
    }

    if ($Text -match "not responding") {
        return "not_responding"
    }

    if ($Text -match "another Unity instance is running with this project open" -or
        $Text -match "Multiple Unity instances cannot open the same project" -or
        $Text -match "Project already open") {
        return "project_locked"
    }

    if ($Text -match "connection closed before response") {
        return "reloading"
    }

    return "unknown"
}

function Invoke-UnityCliRaw {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Args
    )

    $outputLines = & unity-cli @Args 2>&1 | ForEach-Object { "$_" }
    $outputText = ($outputLines | Out-String).Trim()
    $exitCode = $LASTEXITCODE
    $state = Get-UnityCliState -Text $outputText

    [pscustomobject]@{
        Args     = $Args
        ExitCode = $exitCode
        Output   = $outputText
        State    = $state
    }
}

function Wait-UnityCliReady {
    param(
        [string]$ResolvedProjectPath,
        [int]$TimeoutSeconds = 60,
        [int]$PollIntervalSeconds = 2
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)

    do {
        $result = Invoke-UnityCliRaw -Args (@(Get-UnityCliProjectArgs -ResolvedProjectPath $ResolvedProjectPath) + @("status"))
        if ($result.Output) {
            $result.Output
        }

        switch ($result.State) {
            "ready" {
                return $result
            }
            "no_instance" {
                throw "No Unity instance was found for project '$ResolvedProjectPath'. Open the project in Unity first."
            }
            "project_locked" {
                throw "Unity reports that project '$ResolvedProjectPath' is already open in another instance. Close the conflicting instance or target the right project."
            }
        }

        Start-Sleep -Seconds $PollIntervalSeconds
    } while ((Get-Date) -lt $deadline)

    throw "Unity did not reach ready state within $TimeoutSeconds seconds."
}

function Invoke-UnityCliSafe {
    param(
        [string]$ResolvedProjectPath,
        [Parameter(Mandatory = $true)]
        [string[]]$Args,
        [int]$CommandRetryCount = 0,
        [int]$CommandRetryDelaySeconds = 2,
        [int]$CommandReadyTimeoutSeconds = 60,
        [switch]$CommandWaitForReadyBefore,
        [switch]$CommandWaitForReadyAfter
    )

    if ($CommandWaitForReadyBefore) {
        $null = Wait-UnityCliReady -ResolvedProjectPath $ResolvedProjectPath -TimeoutSeconds $CommandReadyTimeoutSeconds
    }

    $attempt = 0
    while ($true) {
        $attempt++
        $result = Invoke-UnityCliRaw -Args (@(Get-UnityCliProjectArgs -ResolvedProjectPath $ResolvedProjectPath) + $Args)

        if ($result.ExitCode -eq 0) {
            if ($CommandWaitForReadyAfter) {
                $null = Wait-UnityCliReady -ResolvedProjectPath $ResolvedProjectPath -TimeoutSeconds $CommandReadyTimeoutSeconds
            }

            return $result
        }

        switch ($result.State) {
            "no_instance" {
                throw "unity-cli could not find a Unity instance for project '$ResolvedProjectPath'.`n$result.Output"
            }
            "project_locked" {
                throw "unity-cli detected that project '$ResolvedProjectPath' is locked by another Unity instance.`n$result.Output"
            }
        }

        $looksTransient =
            $result.State -in @("not_responding", "reloading") -or
            $result.Output -match "connection closed before response" -or
            $result.Output -match "temporarily unavailable"

        if (-not $looksTransient -or $attempt -gt $CommandRetryCount) {
            throw "unity-cli command failed.`nArgs: $($result.Args -join ' ')`nExitCode: $($result.ExitCode)`n$result.Output"
        }

        Start-Sleep -Seconds $CommandRetryDelaySeconds
    }
}

if ($CliCommandArgs -and $CliCommandArgs.Count -gt 0) {
    $result = Invoke-UnityCliSafe `
        -ResolvedProjectPath $CliProjectPath `
        -Args $CliCommandArgs `
        -CommandRetryCount $CliRetryCount `
        -CommandRetryDelaySeconds $CliRetryDelaySeconds `
        -CommandReadyTimeoutSeconds $CliReadyTimeoutSeconds `
        -CommandWaitForReadyBefore:$CliWaitForReadyBefore `
        -CommandWaitForReadyAfter:$CliWaitForReadyAfter

    if ($result.Output) {
        $result.Output
    }
}
