# Plugin Checklist

每个新插件必须满足以下条件：

- [ ] 有独立目录：`Plugins/<Name>/`
- [ ] 有一个 `<Name>Plugin.swift`
- [ ] 有唯一 `descriptor.id`
- [ ] 绑定一个 `AppFeature`
- [ ] 如需服务，使用 `ServiceRegistry` 注册
- [ ] 如需页面，扩展 `AppRoute` 和 `RouteView`
- [ ] 如需入口，通过 `makeHomeItems` 或 `makeSettingsItems` 暴露
- [ ] 关闭 Feature Flag 后插件不会激活
- [ ] 删除插件目录前，只需要先改 `PluginCatalog` 和 `FeatureFlags`
- [ ] 未配置第三方 Key 时不崩溃
