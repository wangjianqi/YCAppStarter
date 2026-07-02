# YCAppStarter V2.5 Release Notes

## Focus

V2.5 turns the previous AdMob compliance checklist into a real monetization adapter:

- Google Mobile Ads SDK via Swift Package Manager
- Google User Messaging Platform via Swift Package Manager
- Banner, interstitial and rewarded abstractions
- Remote Config ad switches
- Review Safe Mode / Kill Switch suppression
- UMP consent gating
- Ad Debug screen
- AdMob configuration script

## Migration from V2.4

1. Regenerate the Xcode project.
2. Resolve new Swift Package dependencies.
3. Keep sample ad IDs for development.
4. Configure production IDs with `Scripts/configure_admob.py` before release.
5. Enable Remote Config ad switches only after UMP and app-ads.txt are validated.

## New Remote Config keys

```json
{
  "admob_banner_enabled": false,
  "admob_interstitial_enabled": false,
  "admob_rewarded_enabled": false
}
```

## Safety defaults

V2.5 still ships with ads disabled by remote defaults. This is intentional. It prevents accidental ad loading in review builds and makes the template safe to run immediately.
