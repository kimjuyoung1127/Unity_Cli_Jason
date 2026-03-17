# Validation Workflow

Use this order when validating a Unity project with `unity-cli`.

Prefer targeting the project explicitly and waiting until Unity is `ready` before chaining commands after any compile, menu execution, or build-target switch.

## 1. Environment

```powershell
./scripts/wait-unity-ready.ps1 -ProjectPath C:/Path/To/YourProject
unity-cli --project C:/Path/To/YourProject status
unity-cli --project C:/Path/To/YourProject list
unity-cli --project C:/Path/To/YourProject compile_check_tool
```

## 2. Static validation

```powershell
unity-cli --project C:/Path/To/YourProject console_check_tool --params '{"type":"error"}'
unity-cli --project C:/Path/To/YourProject scene_validate_tool --params '{"name":"all"}'
unity-cli --project C:/Path/To/YourProject prefab_validate_tool --params '{"path":"Assets/SomePrefab.prefab"}'
unity-cli --project C:/Path/To/YourProject build_settings_tool
unity-cli --project C:/Path/To/YourProject asmdef_validate_tool
unity-cli --project C:/Path/To/YourProject resource_validate_tool
```

## 3. Domain checks

```powershell
unity-cli --project C:/Path/To/YourProject robot_catalog_tool
unity-cli --project C:/Path/To/YourProject fk_compute_tool --params '{"template":"ExampleBot","joints":"0,45"}'
```

## 4. Tests

If your project defines wrapper tools, prefer them in PowerShell:

```powershell
unity-cli --project C:/Path/To/YourProject run_edit_mode_tests_tool
unity-cli --project C:/Path/To/YourProject get_test_results_tool
```

If you only have `run_tests_tool`, use your project's stable wrapper or helper script instead of assuming raw JSON params will behave identically in every shell.
