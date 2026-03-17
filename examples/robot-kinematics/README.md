# Robot Kinematics Example

```powershell
$PSNativeCommandArgumentPassing = "Standard"
unity-cli fk_compute_tool --params '{"template":"ExampleBot","joints":"0,45"}'
unity-cli pose_compare_tool --params '{"template":"ExampleBot","joints_a":"0,0","joints_b":"45,30"}'
```
