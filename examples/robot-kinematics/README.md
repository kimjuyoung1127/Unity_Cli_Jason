# Robot Kinematics Example

```powershell
$PSNativeCommandArgumentPassing = "Standard"
unity-cli fk_compute_tool --params '{"template":"FR5","joints":"0,-45,0,-59,-92,-42"}'
unity-cli pose_compare_tool --params '{"template":"2DOF_RR","joints_a":"0,0","joints_b":"45,30"}'
```
