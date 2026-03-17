[CmdletBinding()]
param(
    [string]$ProjectPath,
    [int]$ReadyTimeoutSeconds = 60
)

$ErrorActionPreference = "Stop"
$PSNativeCommandArgumentPassing = "Standard"
$PSNativeCommandUseErrorActionPreference = $false

Get-Command unity-cli | Out-Null
Write-Host "[OK] unity-cli found"

. (Join-Path $PSScriptRoot "..\..\scripts\invoke-unity-cli-safe.ps1")

function Test-ToolPresent {
    param(
        [Parameter(Mandatory = $true)][string]$ToolName,
        [Parameter(Mandatory = $true)][string]$ListText
    )

    return $ListText -match ('"name": "' + [regex]::Escape($ToolName) + '"')
}

$null = Wait-UnityCliReady -ResolvedProjectPath $ProjectPath -TimeoutSeconds $ReadyTimeoutSeconds
$listResult = Invoke-UnityCliSafe -ResolvedProjectPath $ProjectPath -Args @("list")
$listText = $listResult.Output
if ($listText) {
    $listText
}
$compileResult = Invoke-UnityCliSafe -ResolvedProjectPath $ProjectPath -Args @("compile_check_tool")
if ($compileResult.Output) {
    $compileResult.Output
}
$consoleResult = Invoke-UnityCliSafe -ResolvedProjectPath $ProjectPath -Args @("console_check_tool", "--params", '{"type":"error"}')
if ($consoleResult.Output) {
    $consoleResult.Output
}

if (Test-ToolPresent -ToolName "run_edit_mode_tests_tool" -ListText $listText) {
    $testResult = Invoke-UnityCliSafe -ResolvedProjectPath $ProjectPath -Args @("run_edit_mode_tests_tool")
    if ($testResult.Output) {
        $testResult.Output
    }
}
