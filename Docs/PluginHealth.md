# Plugin Health

YCAppStarter V2.1 adds a first-class plugin health model. The goal is to make plugins safe to add, disable, remove and diagnose.

## Runtime model

Each active plugin can contribute:

- `PluginHealthStatus`
- `PluginHealthCheckResult[]`
- Debug items
- Required secrets through `PluginDescriptor.requiredSecrets`
- Required and optional dependencies through `PluginDescriptor`

The Debug panel aggregates these into `PluginHealthReport` entries.

## Recommended plugin health rules

A plugin should return:

- `.ready` when it can run without developer action.
- `.warning` when it is valid for development but not production, for example `NoopPurchaseManager`.
- `.missingConfiguration` when a required API key, plist or backend URL is missing.
- `.missingDependency` when another feature is required but disabled.
- `.missingService` when the plugin expected a service to be registered but it is not available.
- `.failed` for runtime initialization failures.

## Example

```swift
func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
    [
        PluginHealthCheckResult(
            id: "purchase-service-registered",
            title: "PurchaseManaging service",
            status: container.services.contains(PurchaseManaging.self)
                ? .ready
                : .missingService("PurchaseManaging is not registered."),
            recoverySuggestion: "Register RevenueCatPurchaseManager in PurchasePlugin."
        )
    ]
}
```

## Production rule

A production app should have no `.error` health status. Warnings can be acceptable during development, but warnings from monetization, analytics or privacy-related plugins should be resolved before App Store submission.
