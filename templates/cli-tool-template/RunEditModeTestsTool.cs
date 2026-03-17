using Newtonsoft.Json.Linq;
using UnityCliConnector;

namespace ExampleProject.Editor.CliTools
{
    [UnityCliTool(Description = "Launch EditMode tests without requiring JSON params")]
    public static class RunEditModeTestsTool
    {
        public static object HandleCommand(JObject @params)
        {
            return RunTestsTool.HandleCommand(JObject.Parse("{\"mode\":\"edit\"}"));
        }
    }
}
