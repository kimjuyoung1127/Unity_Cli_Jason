using System;
using System.IO;
using System.Linq;
using Newtonsoft.Json.Linq;
using UnityCliConnector;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace ExampleProject.Editor.CliTools
{
    [UnityCliTool(Description = "Open a scene by path or name and optionally enter PlayMode")]
    public static class OpenSceneTool
    {
        public static object HandleCommand(JObject @params)
        {
            var p = new ToolParams(@params);
            var sceneRef = p.Get("scene", string.Empty);
            var enterPlayMode = p.GetBool("enter_play_mode", false);

            if (string.IsNullOrWhiteSpace(sceneRef))
            {
                return new ErrorResponse("Parameter 'scene' is required.");
            }

            var resolvedPath = ResolveScenePath(sceneRef);
            if (string.IsNullOrWhiteSpace(resolvedPath))
            {
                return new ErrorResponse($"Could not resolve scene '{sceneRef}'.");
            }

            var openedScene = EditorSceneManager.OpenScene(resolvedPath, OpenSceneMode.Single);
            var playModeStarted = false;
            if (enterPlayMode && !EditorApplication.isPlaying)
            {
                EditorApplication.isPlaying = true;
                playModeStarted = true;
            }

            return new SuccessResponse($"Opened scene '{openedScene.path}'.", new
            {
                scene = openedScene.path,
                entered_play_mode = playModeStarted
            });
        }

        private static string ResolveScenePath(string sceneRef)
        {
            if (sceneRef.EndsWith(".unity", StringComparison.OrdinalIgnoreCase) && File.Exists(sceneRef))
            {
                return sceneRef.Replace('\\', '/');
            }

            foreach (var scene in EditorBuildSettings.scenes)
            {
                if (string.Equals(Path.GetFileNameWithoutExtension(scene.path), sceneRef, StringComparison.OrdinalIgnoreCase))
                {
                    return scene.path;
                }
            }

            return AssetDatabase.FindAssets($"t:Scene {sceneRef}")
                .Select(AssetDatabase.GUIDToAssetPath)
                .FirstOrDefault();
        }
    }
}
