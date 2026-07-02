# UMPConsentPlugin

`UMPConsentPlugin` wraps Google's User Messaging Platform SDK behind `AdConsentManaging`.

## Lifecycle

On launch, the plugin calls:

```swift
await AdConsentManaging.requestConsentIfNeeded()
```

The Google implementation requests updated consent info and presents required forms when possible.

## Why this is separate from AdMobPlugin

Ad consent is a prerequisite for ad loading. Keeping UMP separate lets you:

- disable AdMob while keeping privacy options available
- test consent without loading ads
- replace Google UMP with another CMP later
- avoid coupling consent UI to ad placements

## Runtime contract

`AdMobPlugin` should not load ads unless:

```swift
AdConsentManaging.canRequestAds == true
```

The starter enforces this through `AdPolicy`.

## Testing

Use `Ad Debug`:

- Request Consent Update
- Present Privacy Options
- Reset Consent For Testing

Do not call reset in production behavior. It is only exposed for debug/testing.
