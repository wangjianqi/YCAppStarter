# YCAppStarter V3.1

Production-ready, plugin-first SwiftUI starter kit for independent iOS apps.

## What is included

- Plugin architecture with health checks.
- RevenueCat, Firebase, AdMob/UMP, AI Proxy, Supabase Auth, Push, Deep Links, Account Center, WidgetKit, Live Activities and Dynamic Island starter modules.
- App Store Launch Kit with metadata, privacy and compliance templates.
- Remote Config and Review Safe Mode.
- V3.0 Production Hardening Kit: multi-environment config, StoreKit test, CI hooks, preflight checks, event catalog, unit test skeleton and commercial packaging templates.

## Start

```bash
brew install xcodegen
./setup.sh --app-name "My App" --bundle-id "com.yourcompany.myapp" --accent "#B8FF2C"
python3 Scripts/ycstarter.py validate
xcodegen generate
open YCAppStarter.xcodeproj
```

## Production gate

```bash
python3 Scripts/validate_production.py
python3 Scripts/appstore_preflight.py
python3 Scripts/validate_storekit.py
```

## Version

Current starter version: `3.1.0`.


## V3.1 Production Stabilization

V3.1 focuses on production readiness rather than new feature surfaces.

```bash
python3 Scripts/ycstarter.py init   --app-name "My App"   --bundle-id com.company.myapp   --app-group group.com.company.myapp   --url-scheme myapp

python3 Scripts/ycstarter.py validate --strict
```

The initializer updates the app target, widget extension, App Group, URL scheme, build settings, entitlements and core template defaults in one pass.
