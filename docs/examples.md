# Examples

## Safe compile and console check

```powershell
$PSNativeCommandArgumentPassing = "Standard"
./scripts/invoke-unity-cli-safe.ps1 compile_check_tool
./scripts/invoke-unity-cli-safe.ps1 console_check_tool --params '{"type":"error"}'
```

## Scene validation

```powershell
./scripts/invoke-unity-cli-safe.ps1 scene_validate_tool --params '{"name":"all"}'
./scripts/invoke-unity-cli-safe.ps1 scene_hierarchy_tool --params '{"depth":2}'
```

## Scene contract validation

```powershell
./scripts/invoke-unity-cli-safe.ps1 scene_contract_validate_tool --params '{\"scene\":\"Assets/Scenes/Main.unity\",\"required_objects\":[\"Canvas\",\"EventSystem\"],\"forbidden_objects\":[\"legacy_panel\"],\"unique_names\":[\"joint_slider_1\",\"joint_slider_2\"]}'
```

## Duplicate object audit

```powershell
./scripts/invoke-unity-cli-safe.ps1 duplicate_object_audit_tool --params '{\"scene\":\"Assets/Scenes/Main.unity\",\"include_inactive\":true,\"name_prefixes\":[\"legacy_\"],\"fail_on_duplicates\":false}'
```

## Open a scene directly

```powershell
./scripts/invoke-unity-cli-safe.ps1 open_scene_tool --params '{\"scene\":\"Assets/Scenes/Main.unity\",\"enter_play_mode\":false}'
```

## Generic batch `executeMethod`

```powershell
./scripts/invoke-unity-batch-method.ps1 `
  -ProjectPath C:/Path/To/YourProject `
  -ExecuteMethod ExampleProject.Editor.BuildRunner.Build `
  -SuccessPattern 'Build Finished, Result: Success\.'
```
