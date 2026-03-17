# Getting Started

This toolkit is for Unity developers who want a clean, repeatable way to use `unity-cli` in editor-driven and agent-assisted workflows.

## 1. Install `unity-cli`

```powershell
irm https://raw.githubusercontent.com/youngwoocho02/unity-cli/master/install.ps1 | iex
```

## 2. Verify command resolution

```powershell
Get-Command unity-cli
unity-cli --version
```

## 3. Open your Unity project

Make sure Unity is already open with the `unity-cli` connector package installed.

## 4. Check editor connectivity

```powershell
unity-cli status
unity-cli list
```

## 5. Run your first safe validation command

```powershell
$PSNativeCommandArgumentPassing = "Standard"
unity-cli compile_check_tool
```
