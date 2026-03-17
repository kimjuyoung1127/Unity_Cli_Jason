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
