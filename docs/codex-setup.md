# Codex Setup

If Unity MCP works but `unity-cli` does not, the issue is usually command resolution inside the Codex app shell.

## Recommended Windows pattern

1. Install `unity-cli`
2. Verify the installed binary location
3. Add a Codex-visible shim if needed

## Typical checks

```powershell
Get-Command unity-cli
unity-cli --version
unity-cli status
```

## PowerShell argument passing

```powershell
$PSNativeCommandArgumentPassing = "Standard"
unity-cli fk_compute_tool --params '{"template":"FR5","joints":"0,-45,0,-59,-92,-42"}'
```
