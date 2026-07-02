# Versioning

V2 之后按以下方式演进：

| 版本 | 规则 |
|---|---|
| 2.0.x | 修复，不改变插件协议 |
| 2.1.x | 新增插件，不破坏现有插件 |
| 2.x | 可新增可选协议方法，必须提供默认实现 |
| 3.0 | 才允许破坏 `AppPlugin` 协议 |

## 插件协议稳定性

`AppPlugin` 新增方法必须在 extension 里提供默认实现，否则会破坏已有插件。

## 迁移文档要求

每个大版本必须提供：

```text
Docs/Migration/V1ToV2.md
Docs/Migration/V2ToV3.md
```
