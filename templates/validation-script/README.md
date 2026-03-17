# Validation Script Template

This script is a minimal starter for validating a Unity project with `unity-cli`.

Recommended upgrades for real projects:

- accept `-ProjectPath` and always prefer `unity-cli --project ...`
- wait until Unity reports `ready` before chaining commands
- use wrapper tools such as `run_edit_mode_tests_tool` for PowerShell-heavy workflows
