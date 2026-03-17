# Troubleshooting

## `Get-Command unity-cli` fails

- `unity-cli` is not installed
- PATH has not refreshed yet
- Codex cannot see the installed PATH entry

## `Unknown command: compile-check`

Use the registered tool name instead:

```powershell
unity-cli compile_check_tool
```

## `invalid JSON in --params`

```powershell
$PSNativeCommandArgumentPassing = "Standard"
```

If the command is still flaky inside PowerShell scripts, create a wrapper tool with no JSON parameters for the most common workflows, such as `run_edit_mode_tests_tool`.

## Wrong Unity instance

If another Unity project is already open, target the correct editor explicitly:

```powershell
unity-cli --project C:/Path/To/YourProject status
unity-cli --project C:/Path/To/YourProject list
```

## `connection closed before response`

This often happens right after:

- script recompilation
- domain reload
- build target switch
- menu commands that save/reload assets

Wait until `unity-cli --project ... status` reports `ready`, then retry the command.

## Port already in use

If your connector binds to a fixed localhost port, another Unity project may already own it.

- Prefer connector implementations that retry the next free port.
- Make sure the CLI chooses the editor by `--project`, not by assuming the default instance.

## PlayMode tests never finish

Treat PlayMode automation as environment-sensitive until you prove your runner is stable.
