# Unity CLI Toolkit for AI-Assisted Unity Workflows

Build repeatable Unity automation with `unity-cli`: setup guides, custom tool templates, and validation workflows for Codex, Claude, and MCP-style agent workflows.

## Quick Start

```powershell
$PSNativeCommandArgumentPassing = "Standard"
unity-cli --project C:/Path/To/YourProject status
unity-cli --project C:/Path/To/YourProject list
unity-cli --project C:/Path/To/YourProject compile_check_tool
```

## Who this is for

- Unity developers using AI agents in their workflow
- Teams building project-specific `unity-cli` custom tools
- Anyone who wants a repeatable way to inspect, validate, and automate Unity Editor state

## What this repo gives you

- A proven Windows/Codex setup flow for `unity-cli`
- Reusable PowerShell helpers for safe `unity-cli` invocation and Unity batch methods
- Starter templates for writing custom `[UnityCliTool]` commands
- A repeatable validation workflow for compile, console, scene, prefab, resource, and test checks
- Copyable PowerShell examples that work with Unity + `unity-cli`
- Multi-instance guidance for choosing the correct Unity Editor with `--project`
- Safer validation patterns for domain reloads, compile waits, and wrapper tools

## Repo Map

- `docs/` - setup, troubleshooting, workflow documentation
- `templates/` - starter files for custom tools and validation scripts
- `scripts/` - setup and verification helpers
- `examples/` - concrete examples and one project case study

## Example Custom Tool

```powershell
$PSNativeCommandArgumentPassing = "Standard"
unity-cli --project C:/Path/To/YourProject fk_compute_tool --params '{"template":"ExampleBot","joints":"0,45"}'
```

## Example Validation Flow

```powershell
$PSNativeCommandArgumentPassing = "Standard"
./scripts/wait-unity-ready.ps1 -ProjectPath C:/Path/To/YourProject
./scripts/invoke-unity-cli-safe.ps1 -ProjectPath C:/Path/To/YourProject compile_check_tool
./scripts/invoke-unity-cli-safe.ps1 -ProjectPath C:/Path/To/YourProject console_check_tool --params '{"type":"error"}'
./scripts/invoke-unity-cli-safe.ps1 -ProjectPath C:/Path/To/YourProject scene_validate_tool --params '{"name":"all"}'
./scripts/invoke-unity-cli-safe.ps1 -ProjectPath C:/Path/To/YourProject resource_validate_tool
```

## Generic Script Helpers

- `scripts/invoke-unity-cli-safe.ps1`
  - Wraps `unity-cli` calls with stable PowerShell defaults, retry support, and project-aware status handling.
- `scripts/wait-unity-ready.ps1`
  - Waits for the correct Unity project to reach `ready`, but fails fast on `no instance` and `project locked`.
- `scripts/invoke-unity-batch-method.ps1`
  - Runs any Unity `-executeMethod` in batchmode, checks for project-lock conflicts, and can retry once after compile-only passes when you provide a success pattern.

## Codex / Windows Note

- Use registered tool names such as `compile_check_tool`, not guessed kebab-case aliases.
- In PowerShell, prefer `--params '{"key":"value"}'` when passing strings, booleans, or comma-separated values.
- Set `$PSNativeCommandArgumentPassing = "Standard"` before invoking complex commands.
- If more than one Unity project is open, prefer `unity-cli --project C:/Path/To/YourProject ...`.
- After menu execution, recompiles, or build-target switches, wait for `status` to return `ready` before chaining the next command.
- Prefer `scripts/invoke-unity-cli-safe.ps1` inside PowerShell automation when you want retries and clearer failure messages.
- Prefer `scripts/invoke-unity-batch-method.ps1` for batch `-executeMethod` runs instead of hand-writing raw Unity command lines every time.

## Known Reality

- EditMode automation is usually the most reliable baseline.
- PlayMode automation can be environment-sensitive and may require batch or isolated project workflows.
- Custom wrapper tools such as `run_edit_mode_tests_tool` are often more reliable than JSON-heavy test commands in PowerShell scripts.

## Roadmap

- More reusable custom tool templates
- Better PlayMode runner guidance
- More agent-specific setup notes
- Cross-platform examples beyond Windows

## Contributing

Issues and PRs are welcome, especially for:

- New generic custom tool templates
- Better `unity-cli` validation flows
- Cross-project examples
- Windows/macOS/Linux environment notes
