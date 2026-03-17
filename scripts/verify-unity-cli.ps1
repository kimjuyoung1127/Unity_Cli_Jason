[CmdletBinding()]
param(
    [string]$ProjectPath,
    [int]$ReadyTimeoutSeconds = 60
)

$ErrorActionPreference = "Stop"
$PSNativeCommandArgumentPassing = "Standard"
$PSNativeCommandUseErrorActionPreference = $false

. (Join-Path $PSScriptRoot "invoke-unity-cli-safe.ps1")

Get-Command unity-cli | Out-Null
unity-cli --version
$null = Wait-UnityCliReady -ResolvedProjectPath $ProjectPath -TimeoutSeconds $ReadyTimeoutSeconds
$listResult = Invoke-UnityCliSafe -ResolvedProjectPath $ProjectPath -Args @("list")
if ($listResult.Output) {
    $listResult.Output
}
$compileResult = Invoke-UnityCliSafe -ResolvedProjectPath $ProjectPath -Args @("compile_check_tool")
if ($compileResult.Output) {
    $compileResult.Output
}
