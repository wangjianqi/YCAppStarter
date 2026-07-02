# Feature Flags

`FeatureFlags` 决定插件是否激活。

```swift
static let `default` = FeatureFlags(enabledFeatures: [
    .onboarding,
    .paywall,
    .analytics,
    .localNotifications,
    .settings,
    .debugPanel,
    .demoFeature
])
```

## 新增 Feature

1. 在 `AppFeature` 增加 case；
2. 设置 `displayName`；
3. 设置 `introducedIn`；
4. 在插件 descriptor 中绑定该 feature；
5. 在 `FeatureFlags.default` 中决定是否默认启用。

## 后期远程开关

V2 当前是静态 flag。V2.1 可以新增：

```text
RemoteFeatureFlagProvider
FirebaseRemoteConfigFeatureFlagProvider
LocalFeatureFlagProvider
```

但不要一开始让模板依赖 Firebase Remote Config。
