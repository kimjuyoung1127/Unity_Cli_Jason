# Validation Workflow

Use this order when validating a Unity project with `unity-cli`.

Prefer targeting the project explicitly and waiting until Unity is `ready` before chaining commands after any compile, menu execution, or build-target switch.

## 1. Environment

```powershell
./scripts/wait-unity-ready.ps1 -ProjectPath C:/Path/To/YourProject
unity-cli --project C:/Path/To/YourProject status
unity-cli --project C:/Path/To/YourProject list
./scripts/invoke-unity-cli-safe.ps1 -ProjectPath C:/Path/To/YourProject compile_check_tool
```

## 2. Static validation

```powershell
./scripts/invoke-unity-cli-safe.ps1 -ProjectPath C:/Path/To/YourProject console_check_tool --params '{"type":"error"}'
./scripts/invoke-unity-cli-safe.ps1 -ProjectPath C:/Path/To/YourProject scene_validate_tool --params '{"name":"all"}'
./scripts/invoke-unity-cli-safe.ps1 -ProjectPath C:/Path/To/YourProject prefab_validate_tool --params '{"path":"Assets/SomePrefab.prefab"}'
./scripts/invoke-unity-cli-safe.ps1 -ProjectPath C:/Path/To/YourProject build_settings_tool
./scripts/invoke-unity-cli-safe.ps1 -ProjectPath C:/Path/To/YourProject asmdef_validate_tool
./scripts/invoke-unity-cli-safe.ps1 -ProjectPath C:/Path/To/YourProject resource_validate_tool
```

## 3. Domain checks

```powershell
./scripts/invoke-unity-cli-safe.ps1 -ProjectPath C:/Path/To/YourProject robot_catalog_tool
./scripts/invoke-unity-cli-safe.ps1 -ProjectPath C:/Path/To/YourProject fk_compute_tool --params '{"template":"ExampleBot","joints":"0,45"}'
```

## 4. Tests

If your project defines wrapper tools, prefer them in PowerShell:

```powershell
./scripts/invoke-unity-cli-safe.ps1 -ProjectPath C:/Path/To/YourProject run_edit_mode_tests_tool
./scripts/invoke-unity-cli-safe.ps1 -ProjectPath C:/Path/To/YourProject get_test_results_tool
```

If you only have `run_tests_tool`, use your project's stable wrapper or helper script instead of assuming raw JSON params will behave identically in every shell.

## 5. Batch `executeMethod`

When you need a generic batch-mode entry point, prefer the helper script over hand-written Unity command lines:

```powershell
./scripts/invoke-unity-batch-method.ps1 `
  -ProjectPath C:/Path/To/YourProject `
  -ExecuteMethod ExampleProject.Editor.BuildRunner.Build `
  -SuccessPattern 'Build Finished, Result: Success\.'
```

Provide a `-SuccessPattern` when your first batch pass may only compile scripts and exit without fully executing the target method.
