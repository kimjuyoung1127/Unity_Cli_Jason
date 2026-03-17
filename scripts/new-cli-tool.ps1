[CmdletBinding()]
param([Parameter(Mandatory = $true)][string]$ToolName,[Parameter(Mandatory = $true)][string]$OutputPath)

$ErrorActionPreference = "Stop"
$className = $ToolName.Trim()
$filePath = Join-Path $OutputPath ($className + '.cs')
if (!(Test-Path $OutputPath)) { New-Item -ItemType Directory -Path $OutputPath | Out-Null }
@"
using Newtonsoft.Json.Linq;
using UnityCliConnector;

namespace ExampleProject.Editor.CliTools
{
    [UnityCliTool(Description = "$className custom tool")]
    public static class $className
    {
        public static object HandleCommand(JObject @params)
        {
            return new SuccessResponse("$className executed.", new { ok = true });
        }
    }
}
"@ | Set-Content -Path $filePath -Encoding utf8
Write-Host "Created $filePath"
