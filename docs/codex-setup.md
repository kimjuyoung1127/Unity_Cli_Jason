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
unity-cli --project C:/Path/To/YourProject status
./scripts/invoke-unity-cli-safe.ps1 -ProjectPath C:/Path/To/YourProject compile_check_tool
```

## PowerShell argument passing

```powershell
$PSNativeCommandArgumentPassing = "Standard"
unity-cli --project C:/Path/To/YourProject fk_compute_tool --params '{"template":"ExampleBot","joints":"0,45"}'
```

## Multiple Unity instances

If more than one Unity Editor is open, avoid plain `unity-cli status`.

```powershell
unity-cli --project C:/Path/To/YourProject status
unity-cli --project C:/Path/To/YourProject list
```

This removes ambiguity when another project already owns the default port.

## Recommended script-first pattern

For Codex or any PowerShell-heavy automation, prefer the helper scripts in this repo:

```powershell
./scripts/wait-unity-ready.ps1 -ProjectPath C:/Path/To/YourProject
./scripts/invoke-unity-cli-safe.ps1 -ProjectPath C:/Path/To/YourProject compile_check_tool
```
