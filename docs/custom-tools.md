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
