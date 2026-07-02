# Plugin Authoring

## 最小插件

```swift
struct ExportPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.export",
        displayName: "Export",
        version: .v2,
        feature: .export,
        category: .system,
        summary: "Adds export capability."
    )
}
```

## 注册服务

```swift
func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
    registry.register(ExportManaging.self, service: ExportManager())
}
```

## 使用服务

```swift
let exportManager = container.requireService(ExportManaging.self)
```

## 向首页贡献入口

```swift
func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {
    [
        PluginHomeItem(
            id: "export-home",
            title: "Export",
            subtitle: "Export media files",
            systemImage: "square.and.arrow.up",
            route: .pluginDetail(descriptor.id)
        )
    ]
}
```

## 推荐插件结构

```text
Plugins/Export/
├── ExportPlugin.swift
├── ExportManaging.swift
├── ExportManager.swift
├── ExportView.swift
└── ExportModels.swift
```

## 插件边界原则

- 插件可以依赖 Core；
- Core 不允许依赖插件；
- 插件之间不要直接互相 import；
- 插件之间通过 `ServiceRegistry` 或明确的 `dependencies` 协作；
- 第三方 SDK 接入放在插件内部，不要放在 App Shell。
