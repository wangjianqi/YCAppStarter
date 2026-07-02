# StoreKit / RevenueCat Testing

V2.2 is designed to support both RevenueCat Test Store and Apple sandbox testing.

## Recommended development flow

1. Use RevenueCat Test Store API key during local development.
2. Use Apple sandbox / StoreKit configuration when validating App Store Connect products.
3. Never submit a Release build with a Test Store key.
4. Before TestFlight, run:

```bash
python3 Scripts/ycstarter_doctor.py --strict
```

## App Store Connect checklist

- Paid Applications Agreement active.
- Products created and attached to the app.
- Product IDs match RevenueCat.
- Subscription group configured if using subscriptions.
- Products are at least Ready to Submit / approved depending on review stage.
- RevenueCat entitlement ID matches `AppSecrets.revenueCatEntitlementID`.
- RevenueCat offering has packages and is current/default.

## In-app debug checklist

Open `Settings > Purchase Debug` and verify:

- RevenueCat Key = Configured
- PurchaseManaging = Registered
- Products count > 0
- Entitlement = expected ID
