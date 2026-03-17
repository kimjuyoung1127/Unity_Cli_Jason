using System;
using System.Collections.Generic;
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
    [UnityCliTool(Description = "Validate a generic scene contract")]
    public static class SceneContractValidateTool
    {
        public static object HandleCommand(JObject @params)
        {
            var p = new ToolParams(@params);
            var sceneRef = p.Get("scene", string.Empty);
            var includeInactive = p.GetBool("include_inactive", true);
            var requiredObjects = ReadStringArray(@params, "required_objects");
            var forbiddenObjects = ReadStringArray(@params, "forbidden_objects");
            var uniqueNames = ReadStringArray(@params, "unique_names");

            var scene = OpenSceneIfNeeded(sceneRef);
            var transforms = CollectSceneTransforms(scene, includeInactive);
            var names = transforms.Select(t => t.name).ToList();
            var failures = new List<string>();

            foreach (var required in requiredObjects)
            {
                if (!names.Contains(required))
                {
                    failures.Add($"Missing required object '{required}'.");
                }
            }

            foreach (var forbidden in forbiddenObjects)
            {
                if (names.Contains(forbidden))
                {
                    failures.Add($"Found forbidden object '{forbidden}'.");
                }
            }

            foreach (var uniqueName in uniqueNames)
            {
                var count = names.Count(name => string.Equals(name, uniqueName, StringComparison.Ordinal));
                if (count > 1)
                {
                    failures.Add($"Expected unique object name '{uniqueName}', but found {count}.");
                }
            }

            var payload = new
            {
                scene = scene.path,
                include_inactive = includeInactive,
                required_objects = requiredObjects,
                forbidden_objects = forbiddenObjects,
                unique_names = uniqueNames,
                failure_count = failures.Count,
                failures
            };

            if (failures.Count > 0)
            {
                return new ErrorResponse($"Scene contract validation failed for '{scene.path}'.");
            }

            return new SuccessResponse($"Scene contract validation passed for '{scene.path}'.", payload);
        }

        private static Scene OpenSceneIfNeeded(string sceneRef)
        {
            if (string.IsNullOrWhiteSpace(sceneRef))
            {
                return SceneManager.GetActiveScene();
            }

            var resolvedPath = ResolveScenePath(sceneRef);
            if (string.IsNullOrWhiteSpace(resolvedPath))
            {
                throw new FileNotFoundException($"Could not resolve scene '{sceneRef}'.");
            }

            var activeScene = SceneManager.GetActiveScene();
            if (string.Equals(activeScene.path, resolvedPath, StringComparison.OrdinalIgnoreCase))
            {
                return activeScene;
            }

            return EditorSceneManager.OpenScene(resolvedPath, OpenSceneMode.Single);
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

        private static List<Transform> CollectSceneTransforms(Scene scene, bool includeInactive)
        {
            var transforms = new List<Transform>();
            foreach (var root in scene.GetRootGameObjects())
            {
                transforms.AddRange(root.GetComponentsInChildren<Transform>(includeInactive));
            }

            return transforms;
        }

        private static string[] ReadStringArray(JObject @params, string key)
        {
            if (!@params.TryGetValue(key, StringComparison.OrdinalIgnoreCase, out var token) || token == null)
            {
                return Array.Empty<string>();
            }

            return token.Type == JTokenType.Array
                ? token.Values<string>().Where(value => !string.IsNullOrWhiteSpace(value)).ToArray()
                : Array.Empty<string>();
        }
    }
}
