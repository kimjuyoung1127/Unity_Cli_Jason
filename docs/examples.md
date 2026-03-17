# Examples

## Safe compile and console check

```powershell
$PSNativeCommandArgumentPassing = "Standard"
unity-cli compile_check_tool
unity-cli console_check_tool --params '{"type":"error"}'
```

## Scene validation

```powershell
unity-cli scene_validate_tool --params '{"name":"all"}'
unity-cli scene_hierarchy_tool --params '{"depth":2}'
```
