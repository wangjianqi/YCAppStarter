# YCAppStarter V2.4 Release Notes

## Theme

Remote operations and review safety.

## Added

- `RemoteConfigPlugin`
- `RemoteConfigServicing`
- `LocalJSONRemoteConfigService`
- `FirebaseRemoteConfigService`
- `LaunchPolicy`
- `PromotionConfig`
- `RemoteConfigView`
- `ReviewSafeModeView`
- `RemoteConfigDefaults.json`
- `validate_remote_config.py`
- Doctor checks for remote config files, routes, package dependency and JSON defaults

## Changed

- `project.yml` version updated to `2.4.0 / 240`.
- Added Firebase Remote Config SPM product.
- Home and Settings copy updated to V2.4.
- Paywall reads `paywall_enabled` and `paywall_variant`.
- AdMob Compliance displays effective remote ad state.

## Migration from V2.3

1. Copy `Core/RemoteConfig`.
2. Copy `Plugins/RemoteConfig`.
3. Copy `Modules/RemoteConfig` and `Modules/ReviewSafeMode`.
4. Add `RemoteConfigDefaults.json` to resources.
5. Add `.remoteConfig`, `.reviewSafeMode`, `.featureKillSwitch` to FeatureFlags.
6. Add `.remoteConfig` and `.reviewSafeMode` routes.
7. Add `RemoteConfigPlugin()` to `PluginCatalog`.
8. Add `FirebaseRemoteConfig` to `project.yml` if using Firebase.
9. Run:

```bash
python3 Scripts/validate_remote_config.py
python3 Scripts/ycstarter_doctor.py
xcodegen generate
```
