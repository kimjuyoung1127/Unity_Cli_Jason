# CLI Tool Template

Copy `ExampleTool.cs` into your Unity Editor assembly and rename it for your project.

Included generic starter templates:

- `ExampleTool.cs`
- `RunEditModeTestsTool.cs`
- `SceneContractValidateTool.cs`
- `DuplicateObjectAuditTool.cs`
- `OpenSceneTool.cs`

Template guidelines:

- Keep logs and user-facing messages in English.
- Keep names and parameter shapes generic so they can be reused across projects.
- Prefer arrays and booleans passed through `--params` rather than hardcoded scene or object names.
