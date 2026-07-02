# AdMob Compliance

V2.3 includes an AdMob compliance surface, but it does not integrate Google Mobile Ads SDK by default.

## Before Enabling Ads

- Add the Google Mobile Ads SDK.
- Add `GADApplicationIdentifier` to `Info.plist`.
- Add real `admobAppID` to `AppSecrets.swift`.
- Integrate UMP consent flow before loading ads where required.
- Use test ad units or test device IDs during development.
- Publish `app-ads.txt` at the developer website root.
- Complete `Metadata/review_notes.md` and `Metadata/privacy_answers.md`.

## app-ads.txt Check

```bash
python3 Scripts/check_app_ads_txt.py \
  --domain example.com \
  --publisher pub-0000000000000000
```

## Recommended Plugin Direction

Keep AdMob runtime code in a future `AdMobPlugin`. Keep compliance checks in `AdMobCompliancePlugin` so apps that do not show ads can delete the runtime plugin while keeping release documentation.
