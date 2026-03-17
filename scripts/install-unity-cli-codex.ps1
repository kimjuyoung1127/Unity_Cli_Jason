[CmdletBinding()]
param([string]$CodexBin = "$env:LOCALAPPDATA\OpenAI\Codex\bin")

$ErrorActionPreference = "Stop"
irm https://raw.githubusercontent.com/youngwoocho02/unity-cli/master/install.ps1 | iex

if (!(Test-Path $CodexBin)) { New-Item -ItemType Directory -Path $CodexBin | Out-Null }
$unityCliExe = Join-Path $env:LOCALAPPDATA 'unity-cli\unity-cli.exe'
$shimPath = Join-Path $CodexBin 'unity-cli.cmd'
@"
@echo off
"$unityCliExe" %*
"@ | Set-Content -Path $shimPath -Encoding ascii
Write-Host "Created Codex shim at $shimPath"
