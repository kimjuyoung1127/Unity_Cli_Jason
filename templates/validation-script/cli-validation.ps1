[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$PSNativeCommandArgumentPassing = "Standard"

Get-Command unity-cli | Out-Null
Write-Host "[OK] unity-cli found"

unity-cli status
unity-cli list
unity-cli compile_check_tool
unity-cli console_check_tool --params '{"type":"error"}'
