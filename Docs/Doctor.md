# Doctor

Run static checks before generating the Xcode project:

```bash
python3 Scripts/validate_remote_config.py
python3 Scripts/ycstarter_doctor.py
python3 Scripts/check_localization.py
```

## V2.4 checks

- Required starter files exist.
- Plugin files are registered in `PluginCatalog`.
- Plugin descriptor features exist in `AppFeature`.
- Project version is `2.4.0 / 240`.
- RevenueCat/Firebase package dependencies exist.
- Firebase Remote Config package dependency exists.
- Privacy manifest exists and parses.
- Remote config defaults exist and contain required keys.
- Routes exist for commercial, launch and remote operation modules.
- Metadata templates exist.
- Expected warnings are reported for missing real secrets.

Use strict mode in CI:

```bash
python3 Scripts/ycstarter_doctor.py --strict
```
