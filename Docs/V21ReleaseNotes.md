# YCAppStarter V2.1 Release Notes

V2.1 focuses on plugin stability and diagnostics.

## Added

- Plugin health model.
- Runtime health reports.
- Plugin detail health screen.
- Enhanced Debug panel.
- Descriptor metadata for optional dependencies, required secrets and minimum iOS version.
- Static `ycstarter_doctor.py` command.
- Updated `new_plugin.py` generator with health hooks.
- Documentation for plugin health and doctor checks.

## Not included

V2.1 intentionally does not hard-wire RevenueCat, Firebase, AdMob or Supabase. These belong in V2.2+ as real production plugins.
