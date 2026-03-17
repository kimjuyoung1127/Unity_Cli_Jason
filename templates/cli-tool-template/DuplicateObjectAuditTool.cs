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
    [UnityCliTool(Description = "Audit duplicate object names in a scene")]
    public static class DuplicateObjectAuditTool
    {
        public static object HandleCommand(JObject @params)
        {
            var p = new ToolParams(@params);
            var sceneRef = p.Get("scene", string.Empty);
            var includeInactive = p.GetBool("include_inactive", true);
            var failOnDuplicates = p.GetBool("fail_on_duplicates", false);
            var prefixes = ReadStringArray(@params, "name_prefixes");

            var scene = OpenSceneIfNeeded(sceneRef);
            var transforms = CollectSceneTransforms(scene, includeInactive);
            var duplicates = transforms
                .Where(transform => PrefixMatches(transform.name, prefixes))
                .GroupBy(transform => transform.name)
                .Where(group => group.Count() > 1)
                .Select(group => new
                {
                    name = group.Key,
                    count = group.Count(),
                    paths = group.Select(item => GetHierarchyPath(item)).ToArray()
                })
                .OrderByDescending(item => item.count)
                .ThenBy(item => item.name, StringComparer.Ordinal)
                .ToArray();

            var payload = new
            {
                scene = scene.path,
                include_inactive = includeInactive,
                name_prefixes = prefixes,
                duplicate_count = duplicates.Length,
                duplicates
            };

            if (duplicates.Length > 0 && failOnDuplicates)
            {
                return new ErrorResponse($"Duplicate object audit failed for '{scene.path}'.");
            }

            return new SuccessResponse($"Duplicate object audit completed for '{scene.path}'.", payload);
        }

        private static bool PrefixMatches(string objectName, string[] prefixes)
        {
            if (prefixes == null || prefixes.Length == 0)
            {
                return true;
            }

            return prefixes.Any(prefix => objectName.StartsWith(prefix, StringComparison.Ordinal));
        }

        private static string GetHierarchyPath(Transform transform)
        {
            var parts = new Stack<string>();
            var current = transform;
            while (current != null)
            {
                parts.Push(current.name);
                current = current.parent;
            }

            return string.Join("/", parts);
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
