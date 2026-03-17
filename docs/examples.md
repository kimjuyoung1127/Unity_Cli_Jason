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

## Generic batch `executeMethod`

```powershell
./scripts/invoke-unity-batch-method.ps1 `
  -ProjectPath C:/Path/To/YourProject `
  -ExecuteMethod ExampleProject.Editor.BuildRunner.Build `
  -SuccessPattern 'Build Finished, Result: Success\.'
```
