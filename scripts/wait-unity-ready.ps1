[CmdletBinding()]
param(
    [string]$ProjectPath,
    [int]$TimeoutSeconds = 60,
    [int]$PollIntervalSeconds = 2
)

$ErrorActionPreference = "Stop"
$PSNativeCommandArgumentPassing = "Standard"
$PSNativeCommandUseErrorActionPreference = $false

. (Join-Path $PSScriptRoot "invoke-unity-cli-safe.ps1")

$null = Wait-UnityCliReady `
    -ResolvedProjectPath $ProjectPath `
    -TimeoutSeconds $TimeoutSeconds `
    -PollIntervalSeconds $PollIntervalSeconds
