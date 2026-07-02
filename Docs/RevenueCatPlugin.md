# RevenueCatPlugin

`RevenueCatPlugin` is the V2.2 production purchase adapter. It overrides the V1/V2 fallback `NoopPurchaseManager` only when `AppSecrets.revenueCatAPIKey` is configured.

## Files

```text
Sources/YCAppStarter/Plugins/RevenueCat/
├── RevenueCatPlugin.swift
├── RevenueCatConfig.swift
└── RevenueCatPurchaseManager.swift
```

## Setup

1. Add your products in App Store Connect.
2. Add the same products to RevenueCat.
3. Create an entitlement, default expected ID: `premium`.
4. Create an offering and make it current/default.
5. Fill:

```swift
AppSecrets(
    revenueCatAPIKey: "appl_xxx",
    revenueCatEntitlementID: "premium",
    revenueCatOfferingID: nil,
    ...
)
```

Set `revenueCatOfferingID` only when you want to force a specific offering. Leave it as `nil` to use RevenueCat's current offering.

## App-facing API

Feature modules should use:

```swift
let purchase = container.service(PurchaseManaging.self)
```

Do not call RevenueCat directly from app screens.

## Debugging

Open:

```text
Settings > Purchase Debug
```

Check:

- API key configured
- Entitlement ID
- Products loaded
- Premium state

## Common failure points

- Wrong API key type.
- Test Store key used in Release.
- Missing App Store Connect products.
- Product IDs mismatch between App Store Connect and RevenueCat.
- No current/default offering.
- Entitlement ID mismatch.
