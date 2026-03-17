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

For scripted automation, prefer:

```powershell
./scripts/invoke-unity-cli-safe.ps1 -ProjectPath C:/Path/To/YourProject compile_check_tool
```

## Port already in use

If your connector binds to a fixed localhost port, another Unity project may already own it.

- Prefer connector implementations that retry the next free port.
- Make sure the CLI chooses the editor by `--project`, not by assuming the default instance.

## `no Unity instance found for project`

This is different from a transient reload.

- Open the target project in Unity first.
- Confirm the script is using the same `--project` path you opened.
- Use `./scripts/wait-unity-ready.ps1 -ProjectPath ...` so the failure is reported immediately instead of timing out.

## `not responding`

This usually means Unity is compiling, reloading, or switching targets.

- Wait and poll again.
- Prefer `./scripts/wait-unity-ready.ps1` before chaining the next command.
- If it persists for several minutes, check whether Unity is blocked on a modal dialog or another long-running task.

## `unity-cli exec` fails with `The filename or extension is too long`

This can happen on Windows when the generated temporary compile command becomes too large.

- Prefer a custom wrapper tool instead of `unity-cli exec` for repeated workflows.
- Prefer `./scripts/invoke-unity-batch-method.ps1` when the action maps cleanly to a static editor method.
- Keep `exec` for short inspection snippets, not for scene rebuild or cleanup flows.

## `another Unity instance is running with this project open`

This is common when a batch build is launched while the same project is already open in the editor.

- Close the conflicting Unity instance, or use the already-open editor with `unity-cli --project ...`.
- For batch automation, prefer `./scripts/invoke-unity-batch-method.ps1`, which checks for this condition before launching a new batch process.

## PlayMode tests never finish

Treat PlayMode automation as environment-sensitive until you prove your runner is stable.
