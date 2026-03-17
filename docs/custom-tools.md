# Custom Tools

`unity-cli` custom tools are Unity Editor-side commands implemented as static classes with `[UnityCliTool]`.

## Basic shape

```csharp
using Newtonsoft.Json.Linq;
using UnityCliConnector;

namespace ExampleProject.Editor.CliTools
{
    [UnityCliTool(Description = "Describe what the tool does")]
    public static class ExampleTool
    {
        public static object HandleCommand(JObject @params)
        {
            var p = new ToolParams(@params);
            string value = p.Get("value", "default");
            return new SuccessResponse("Example success", new { value });
        }
    }
}
```

## Rules

- Use real registered `snake_case` command names
- Prefer `SuccessResponse` / `ErrorResponse`
- Prefer `--params '{"key":"value"}'` for CLI usage
- Keep tool messages and logs in English
- Keep tool names and parameters generic enough to reuse across projects

## Universal tool design rules

- Prefer parameters such as `scene`, `required_objects`, `forbidden_objects`, `unique_names`, and `include_inactive`.
- Avoid project-specific scene names, object names, or feature labels in the tool name itself.
- Return machine-friendly payloads so validation scripts can parse results without string-matching logs.
- Treat wrapper tools as stable entry points for shell automation, especially when the underlying workflow is sensitive to compile, reload, or PlayMode timing.

## Recommended generic tool candidates

- `scene_contract_validate_tool`
  - Validate that a scene contains required objects, excludes forbidden ones, and keeps selected names unique.
- `duplicate_object_audit_tool`
  - Report duplicate object names, optionally filtered by prefixes, and optionally fail when duplicates exist.
- `open_scene_tool`
  - Open a target scene by path or build-settings name, with optional PlayMode entry for smoke validation.

## Wrapper tools for shell stability

For workflows you run constantly in PowerShell, wrapper tools are often better than raw JSON-heavy calls.

Example:

```csharp
using Newtonsoft.Json.Linq;
using UnityCliConnector;

namespace ExampleProject.Editor.CliTools
{
    [UnityCliTool(Description = "Launch EditMode tests without JSON params")]
    public static class RunEditModeTestsTool
    {
        public static object HandleCommand(JObject @params)
        {
            return RunTestsTool.HandleCommand(JObject.Parse("{\"mode\":\"edit\"}"));
        }
    }
}
```

Useful wrapper candidates:

- `run_edit_mode_tests_tool`
- `get_test_results_tool`
- `rebuild_main_scene_tool`
- `android_preflight_tool`
- `android_build_tool`
