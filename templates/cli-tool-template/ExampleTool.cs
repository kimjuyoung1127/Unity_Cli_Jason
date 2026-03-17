using Newtonsoft.Json.Linq;
using UnityCliConnector;

namespace ExampleProject.Editor.CliTools
{
    [UnityCliTool(Description = "Example custom unity-cli tool")]
    public static class ExampleTool
    {
        public static object HandleCommand(JObject @params)
        {
            var p = new ToolParams(@params);
            string value = p.Get("value", "default");
            bool verbose = p.GetBool("verbose", false);

            return new SuccessResponse("Example tool executed.", new
            {
                value,
                verbose
            });
        }
    }
}
