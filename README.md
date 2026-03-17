# Unity CLI Toolkit for AI-Assisted Unity Workflows

Reusable setup guides, custom tool templates, and validation scripts for teams using Unity with `unity-cli`, Codex, Claude, or MCP-style agent workflows.

## Quick Start

```powershell
$PSNativeCommandArgumentPassing = "Standard"
unity-cli status
unity-cli list
unity-cli compile_check_tool
```

## Who this is for

- Unity developers using AI agents in their workflow
- Teams building project-specific `unity-cli` custom tools
- Anyone who wants a repeatable way to inspect, validate, and automate Unity Editor state

## What this repo gives you

- A proven Windows/Codex setup flow for `unity-cli`
- Starter templates for writing custom `[UnityCliTool]` commands
- A repeatable validation workflow for compile, console, scene, prefab, resource, and test checks
- Copyable PowerShell examples that work with Unity + `unity-cli`

## Repo Map

- `docs/` - setup, troubleshooting, workflow documentation
- `templates/` - starter files for custom tools and validation scripts
- `scripts/` - setup and verification helpers
- `examples/` - concrete examples and one project case study

## Example Custom Tool

```powershell
$PSNativeCommandArgumentPassing = "Standard"
unity-cli fk_compute_tool --params '{"template":"FR5","joints":"0,-45,0,-59,-92,-42"}'
```

## Example Validation Flow

```powershell
$PSNativeCommandArgumentPassing = "Standard"
unity-cli compile_check_tool
unity-cli console_check_tool --params '{"type":"error"}'
unity-cli scene_validate_tool --params '{"name":"all"}'
unity-cli resource_validate_tool
unity-cli run_tests_tool --params '{"mode":"edit"}'
unity-cli run_tests_tool --params '{"results":true,"verbose":true}'
```

## Codex / Windows Note

- Use registered tool names such as `compile_check_tool`, not guessed kebab-case aliases.
- In PowerShell, prefer `--params '{"key":"value"}'` when passing strings, booleans, or comma-separated values.
- Set `$PSNativeCommandArgumentPassing = "Standard"` before invoking complex commands.

## Known Reality

- EditMode automation is usually the most reliable baseline.
- PlayMode automation can be environment-sensitive and may require batch or isolated project workflows.

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
