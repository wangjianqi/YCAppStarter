# App Store Launch Kit

YCAppStarter includes a release-readiness layer on top of the plugin runtime.

## Included

- `AppStoreLaunchPlugin`
- `AdMobCompliancePlugin`
- App Store readiness checklist UI
- Privacy manifest audit UI
- Metadata template browser
- Localization audit UI
- `PrivacyInfo.xcprivacy` baseline template
- Metadata templates under `Metadata/`
- Static scripts:
  - `Scripts/ycstarter_doctor.py`
  - `Scripts/check_localization.py`
  - `Scripts/check_app_ads_txt.py`

## Recommended Workflow

1. Run `./setup.sh` for app name, bundle ID and accent color.
2. Fill `AppConfig.swift` legal URLs.
3. Fill `AppSecrets.swift` for RevenueCat, Firebase and AdMob if used.
4. Complete files under `Metadata/`.
5. Run `python3 Scripts/ycstarter_doctor.py`.
6. Run `python3 Scripts/check_localization.py`.
7. Run `python3 Scripts/check_app_ads_txt.py` if the app uses AdMob.
8. Generate project with `xcodegen generate`.
9. Archive and validate in Xcode.

## Design Rule

The Launch Kit is diagnostic and templated. It must not become business logic. App-specific decisions should be documented in `Metadata/` and reflected in `AppConfig.swift`, `AppSecrets.swift` and `PrivacyInfo.xcprivacy`.
