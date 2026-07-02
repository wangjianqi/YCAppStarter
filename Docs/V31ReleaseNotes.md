# YCAppStarter V3.1 Release Notes

V3.1 is a production stabilization release. It intentionally does not add major product features. The focus is making V3.0 safer to clone, configure, validate and ship.

## Added

- One-pass project initialization through `Scripts/setup_config.py init` and `Scripts/ycstarter.py init`.
- `setup.sh` now updates app name, bundle ID, widget bundle ID, App Group, URL scheme, accent color and optional AdMob App ID in one flow.
- Build-setting backed `Info.plist` values for environment, StoreKit testing, verbose logging, App Group, URL scheme and AdMob App ID.
- Build-setting backed entitlements for App Group and APNs environment.
- `StarterSharedConfig` for sharing App Group and URL scheme values between the app target and widget extension.
- Strict validation mode for doctor, CI, preflight and production validation.
- Stale version reference check for active source/scripts/docs.

## Changed

- Version bumped to `3.1.0` / build `310`.
- `project.yml` now wires Development, Staging and Production xcconfig files.
- Production readiness checks now cover default bundle ID, URL scheme, Supabase, AdMob sample IDs, App Group, APNs environment and Firebase plist detection.
- Remote Config V3 release-gate keys are now represented in Swift metadata and fallback defaults.

## Recommended migration

1. Run `python3 Scripts/ycstarter.py validate`.
2. Initialize a real app identity:

```bash
python3 Scripts/ycstarter.py init   --app-name "My App"   --bundle-id com.company.myapp   --app-group group.com.company.myapp   --url-scheme myapp
```

3. Run `python3 Scripts/ycstarter.py validate --strict` before release.
4. Add production credentials for RevenueCat, Firebase, Supabase, AdMob and APNs.
