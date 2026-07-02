# Migration: V1 to V2

## 主要变化

V1：核心服务直接放在 `AppContainer`。

V2：服务由插件注册到 `ServiceRegistry`。

## 迁移步骤

1. 把 V1 的 `analytics`、`purchaseManager`、`notificationManager` 从 `AppContainer` 移除；
2. 新增对应插件；
3. 在插件 `registerServices` 注册服务；
4. View 层通过 `container.service(Protocol.self)` 获取服务；
5. 首页、设置页、Debug 页入口改成插件贡献。

## 迁移原则

主 App 只保留：

- Config
- Flags
- ServiceRegistry
- PluginRuntime
- Router
- Logger

业务能力全部进入插件。
