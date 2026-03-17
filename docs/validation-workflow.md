# Validation Workflow

Use this order when validating a Unity project with `unity-cli`.

## 1. Environment

```powershell
unity-cli status
unity-cli list
unity-cli compile_check_tool
```

## 2. Static validation

```powershell
unity-cli console_check_tool --params '{"type":"error"}'
unity-cli scene_validate_tool --params '{"name":"all"}'
unity-cli prefab_validate_tool --params '{"path":"Assets/SomePrefab.prefab"}'
unity-cli build_settings_tool
unity-cli asmdef_validate_tool
unity-cli resource_validate_tool
```

## 3. Domain checks

```powershell
unity-cli robot_catalog_tool
unity-cli fk_compute_tool --params '{"template":"FR5","joints":"0,-45,0,-59,-92,-42"}'
```

## 4. Tests

```powershell
unity-cli run_tests_tool --params '{"mode":"edit"}'
unity-cli run_tests_tool --params '{"results":true,"verbose":true}'
```
