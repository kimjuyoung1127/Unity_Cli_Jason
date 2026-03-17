[CmdletBinding()]
param(
    [string]$ProjectPath,
    [int]$ReadyTimeoutSeconds = 60
)

$ErrorActionPreference = "Stop"
$PSNativeCommandArgumentPassing = "Standard"

Get-Command unity-cli | Out-Null
Write-Host "[OK] unity-cli found"

function Get-UnityCliArgs {
    if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
        return @()
    }

    return @("--project", $ProjectPath)
}

function Invoke-UnityCli {
    param(
        [Parameter(Mandatory = $true)][string[]]$Args
    )

    return (& unity-cli @Args 2>&1 | Out-String).Trim()
}

function Wait-UnityReady {
    $deadline = (Get-Date).AddSeconds($ReadyTimeoutSeconds)
    do {
        $statusText = Invoke-UnityCli -Args (@(Get-UnityCliArgs) + @("status"))
        $statusText
        if ($statusText -match "ready") {
            return
        }

        Start-Sleep -Seconds 2
    } while ((Get-Date) -lt $deadline)

    throw "Unity did not reach ready state within $ReadyTimeoutSeconds seconds."
}

function Test-ToolPresent {
    param([Parameter(Mandatory = $true)][string]$ToolName)

    $listText = Invoke-UnityCli -Args (@(Get-UnityCliArgs) + @("list"))
    return $listText -match ('"name": "' + [regex]::Escape($ToolName) + '"')
}

Wait-UnityReady
Invoke-UnityCli -Args (@(Get-UnityCliArgs) + @("list"))
Invoke-UnityCli -Args (@(Get-UnityCliArgs) + @("compile_check_tool"))
Invoke-UnityCli -Args (@(Get-UnityCliArgs) + @("console_check_tool", "--params", '{"type":"error"}'))

if (Test-ToolPresent -ToolName "run_edit_mode_tests_tool") {
    Invoke-UnityCli -Args (@(Get-UnityCliArgs) + @("run_edit_mode_tests_tool"))
}
