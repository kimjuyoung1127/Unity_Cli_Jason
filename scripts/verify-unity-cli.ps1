[CmdletBinding()]
param(
    [string]$ProjectPath,
    [int]$ReadyTimeoutSeconds = 60
)

$ErrorActionPreference = "Stop"
$PSNativeCommandArgumentPassing = "Standard"

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
            return $statusText
        }

        Start-Sleep -Seconds 2
    } while ((Get-Date) -lt $deadline)

    throw "Unity did not reach ready state within $ReadyTimeoutSeconds seconds."
}

Get-Command unity-cli | Out-Null
unity-cli --version
$null = Wait-UnityReady
Invoke-UnityCli -Args (@(Get-UnityCliArgs) + @("list"))
Invoke-UnityCli -Args (@(Get-UnityCliArgs) + @("compile_check_tool"))
