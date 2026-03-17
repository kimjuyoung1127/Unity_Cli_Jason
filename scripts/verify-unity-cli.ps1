[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$PSNativeCommandArgumentPassing = "Standard"
Get-Command unity-cli | Out-Null
unity-cli --version
unity-cli status
unity-cli list
unity-cli compile_check_tool
