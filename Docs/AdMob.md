# AdMobPlugin

YCAppStarter includes a real Google Mobile Ads adapter while keeping the starter safe by default.

## What is included

- `AdManaging` protocol
- `GoogleAdMobManager`
- `AdMobPlugin`
- SwiftUI `AdMobBannerView`
- Interstitial load / show wrappers
- Rewarded load / show wrappers
- Remote Config placement switches
- UMP consent gating
- Review Safe Mode suppression
- Premium ad-free suppression
- `AdDebugView`

## Default behavior

The starter ships with Google sample IDs and all Remote Config ad switches disabled:

```json
{
  "ads_enabled": false,
  "admob_banner_enabled": false,
  "admob_interstitial_enabled": false,
  "admob_rewarded_enabled": false
}
```

This means the SDK can be integrated without accidentally showing ads in review-safe or unconfigured builds.

## Configure production IDs

```bash
python3 Scripts/configure_admob.py \
  --app-id ca-app-pub-1234567890123456~1234567890 \
  --banner ca-app-pub-1234567890123456/1111111111 \
  --interstitial ca-app-pub-1234567890123456/2222222222 \
  --rewarded ca-app-pub-1234567890123456/3333333333
```

The script updates:

- `Sources/YCAppStarter/Info.plist`
- `Sources/YCAppStarter/Config/AppSecrets.swift`

## Runtime policy

Ads are loaded only when all of these are true:

- `ads_enabled=true`
- the placement-specific switch is true
- Review Safe Mode is false
- Global Kill Switch is false
- user is not premium
- UMP `canRequestAds=true`

## Placement switches

| Key | Purpose |
|---|---|
| `admob_banner_enabled` | Allows banner placements |
| `admob_interstitial_enabled` | Allows interstitial placements |
| `admob_rewarded_enabled` | Allows rewarded placements |

## Where to test

Open:

```text
Home → Ad Debug
```

Use this screen to:

- request UMP consent update
- open privacy options
- start the Google Mobile Ads SDK
- load/show interstitial
- load/show rewarded
- preview banner suppression state

## Release checklist

Before App Store release:

1. Replace all sample IDs.
2. Add full SKAdNetwork IDs required by Google and mediation partners.
3. Confirm app-ads.txt is reachable.
4. Confirm UMP Privacy & messaging message exists in AdMob.
5. Confirm App Privacy answers include advertising identifiers and tracking behavior if applicable.
6. Disable Review Safe Mode only after the app is approved and you are ready to enable ads.
