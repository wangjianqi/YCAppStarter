# Quick Start

```bash
brew install xcodegen

./setup.sh \
  --app-name "My App" \
  --bundle-id "com.yourcompany.myapp" \
  --accent "#B8FF2C"

python3 Scripts/validate_remote_config.py
python3 Scripts/ycstarter_doctor.py
python3 Scripts/check_localization.py
xcodegen generate
open YCAppStarter.xcodeproj
```

## Configure Commercial SDKs

- RevenueCat: fill `AppSecrets.revenueCatAPIKey`.
- Firebase: add `GoogleService-Info.plist` to `Sources/YCAppStarter/Resources/`.
- Remote Config: update `RemoteConfigDefaults.json` and mirror keys in Firebase Remote Config if needed.

## Before App Review

Open the app and check:

- App Store Launch
- Privacy Manifest Audit
- AdMob Compliance
- Remote Config
- Review Safe Mode


## V2.9 Widget Validation

```bash
python3 Scripts/validate_widgets.py
```
