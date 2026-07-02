# YCAppStarter Remote Config

Remote Config adds a remote operations layer for App Review safety, emergency feature shutdowns, paywall variant control, ad display control and promotion campaigns.

## Files

```text
Sources/YCAppStarter/Core/RemoteConfig/
Sources/YCAppStarter/Plugins/RemoteConfig/
Sources/YCAppStarter/Modules/RemoteConfig/
Sources/YCAppStarter/Resources/RemoteConfigDefaults.json
Scripts/validate_remote_config.py
```

## Runtime Model

```text
Business Surface
  ↓
LaunchPolicy / PromotionConfig
  ↓
RemoteConfigServicing
  ↓
FirebaseRemoteConfigService or LocalJSONRemoteConfigService
  ↓
RemoteConfigDefaults.json fallback
```

The app must remain launchable without Firebase. If `GoogleService-Info.plist` is missing, the starter uses `RemoteConfigDefaults.json`.

## Critical Keys

| Key | Type | Purpose |
|---|---|---|
| `review_safe_mode_enabled` | Bool | Suppresses risky review-time surfaces. |
| `feature_kill_switch_enabled` | Bool | Global emergency kill switch. |
| `paywall_enabled` | Bool | Controls paywall surfaces. |
| `paywall_variant` | String | `minimal`, `visualHero`, or `comparison`. |
| `ads_enabled` | Bool | Controls ad placements. |
| `promotion_banner_enabled` | Bool | Controls promotion surfaces. |
| `promotion_title` | String | Promotion title. |
| `promotion_message` | String | Promotion message. |
| `minimum_supported_build` | Int | Reserved for force-upgrade flows. |
| `maintenance_message` | String | Reserved for maintenance notices. |

## Validate Defaults

```bash
python3 Scripts/validate_remote_config.py
```

Use `--strict` in CI if warnings should fail the build.

## Firebase Remote Config

The starter includes `FirebaseRemoteConfigService` and adds the `FirebaseRemoteConfig` SPM product in `project.yml`.

To enable remote fetches:

1. Add `GoogleService-Info.plist` to `Sources/YCAppStarter/Resources/`.
2. Ensure `FirebasePlugin` is enabled.
3. Keep `RemoteConfigPlugin` enabled.
4. Define the critical keys in Firebase Remote Config.
5. Run `python3 Scripts/ycstarter_doctor.py`.

## Recommended Defaults

For normal production:

```json
{
  "review_safe_mode_enabled": false,
  "feature_kill_switch_enabled": false,
  "paywall_enabled": true,
  "paywall_variant": "minimal",
  "ads_enabled": false
}
```

For App Review:

```json
{
  "review_safe_mode_enabled": true,
  "feature_kill_switch_enabled": false,
  "paywall_enabled": true,
  "ads_enabled": true
}
```

Effective runtime policy will still suppress paywall and ad surfaces when Review Safe Mode is enabled.
