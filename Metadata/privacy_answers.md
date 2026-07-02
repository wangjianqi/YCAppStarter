# App Privacy Answers Preparation

Keep this file aligned with App Store Connect privacy answers, PrivacyInfo.xcprivacy and SDK behavior.

## Data Collection Matrix

| Data Type | Collected? | Linked to User? | Used for Tracking? | Purpose | SDK / Feature |
|---|---:|---:|---:|---|---|
| Purchases | Yes/No | Yes/No | Yes/No | App Functionality | RevenueCat / StoreKit |
| Product Interaction | Yes/No | Yes/No | Yes/No | Analytics | Firebase Analytics |
| Crash Data | Yes/No | Yes/No | Yes/No | Diagnostics | Firebase Crashlytics |
| Advertising Data | Yes/No | Yes/No | Yes/No | Advertising | AdMob |
| User Content | Yes/No | Yes/No | Yes/No | App Functionality | App-specific |

## Tracking

- Does the app track users across apps or websites owned by other companies?
- Does the app use IDFA?
- Does the app show third-party ads?
- Does the app share data with data brokers or ad networks?

## Review Before Submission

- SDK list matches the final build.
- PrivacyInfo.xcprivacy matches required-reason API usage.
- App Store Connect answers match actual runtime behavior.
