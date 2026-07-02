# Review Safe Mode

Review Safe Mode is a runtime switch intended to reduce App Review risk without shipping a separate review build.

## What It Does

When `review_safe_mode_enabled=true`, the effective launch policy suppresses:

- aggressive paywall entry points;
- ad placements;
- promotion banners;
- experimental growth surfaces that read `LaunchPolicy`.

It does not remove legal pages, settings, basic app functionality or diagnostics.

## Recommended Use

Before submitting a build:

1. Set `review_safe_mode_enabled=true` in Firebase Remote Config or local defaults.
2. Verify `ReviewSafeModeView`.
3. Confirm Settings still exposes Privacy Policy, Terms and EULA.
4. Submit the build.
5. After approval, set `review_safe_mode_enabled=false` remotely.

## Implementation Rule

New plugins should read remote policy before showing risky surfaces:

```swift
let remoteConfig = container.service(RemoteConfigServicing.self)
let policy = remoteConfig.map(LaunchPolicy.make(from:))

if policy?.reviewSafeModeEnabled == true {
    // Hide ads, campaigns, aggressive paywalls or experiments.
}
```

## Difference from Kill Switch

| Switch | Use |
|---|---|
| `review_safe_mode_enabled` | App Review / compliance-safe launch mode. |
| `feature_kill_switch_enabled` | Emergency shutdown for growth and monetization surfaces. |

The kill switch is stronger and should be reserved for incidents.
