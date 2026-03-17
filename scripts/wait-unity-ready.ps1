[CmdletBinding()]
param(
    [string]$ProjectPath,
    [int]$TimeoutSeconds = 60
)

$ErrorActionPreference = "Stop"
$PSNativeCommandArgumentPassing = "Standard"

function Get-UnityCliArgs {
    if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
        return @()
    }

    return @("--project", $ProjectPath)
}

$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
do {
    $statusText = (& unity-cli @(Get-UnityCliArgs) status 2>&1 | Out-String).Trim()
    $statusText
    if ($statusText -match "ready") {
        exit 0
    }

    Start-Sleep -Seconds 2
} while ((Get-Date) -lt $deadline)

throw "Unity did not reach ready state within $TimeoutSeconds seconds."
