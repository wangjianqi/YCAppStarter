# Privacy Manifest

`Sources/YCAppStarter/Resources/PrivacyInfo.xcprivacy` is included as a baseline template.

## Baseline Keys

- `NSPrivacyTracking`
- `NSPrivacyTrackingDomains`
- `NSPrivacyCollectedDataTypes`
- `NSPrivacyAccessedAPITypes`

## Required Review Before Release

Update the manifest whenever you add:

- File/cache helpers that read file timestamps.
- Disk space checks.
- UserDefaults access patterns that require disclosure.
- Third-party SDKs that collect data or use required-reason APIs.
- Ads, attribution SDKs, analytics or crash reporting.

## Practical Rule

Do not treat the baseline file as final. It is intentionally empty so the starter can run. Each app must update it based on actual SDKs and APIs.
