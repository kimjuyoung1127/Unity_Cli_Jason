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

## PlayMode tests never finish

Treat PlayMode automation as environment-sensitive until you prove your runner is stable.
