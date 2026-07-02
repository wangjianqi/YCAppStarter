# YCAppStarter V3.1

生产级、插件优先的 SwiftUI 独立 iOS 应用启动套件。

## 概述

YCAppStarter 是一个面向独立 iOS 开发者的完整项目模板，采用**插件架构**，内置了独立 App 所需的各种基础设施模块。你可以通过开关功能开关（Feature Flags）来按需启用/禁用功能，而非从零搭建。

### 三层架构

```
App Shell（App 壳）
    ↓
Plugin Runtime + Service Registry（插件运行时 + 服务注册中心）
    ↓
Feature Plugins（功能插件）
```

- `Core/` — 定义协议、模型和通用运行时服务
- `Plugins/` — 具体实现和 SDK 适配器（每个功能是一个独立插件）
- `Modules/` — SwiftUI 界面模块
- 业务代码通过 `AppContainer` 解析服务，而非直接导入 SDK

## 内置功能

| 类别 | 功能 |
|------|------|
 | **商业化** | RevenueCat 内购、AdMob 广告、UMP 用户同意 |
| **用户系统** | Supabase Auth、账户中心、用户资料 |
| **推送与深度链接** | 远程推送、Firebase Messaging、Deep Links |
| **AI 与后端** | AI Proxy、Backend Kit |
| **运营能力** | Remote Config、Review Safe Mode、Feature Kill Switch |
| **Widget 与 Live Activity** | WidgetKit、Live Activity、Dynamic Island |
| **App Store 发布** | App Store Launch Kit、元数据模板、隐私清单审计、本地化审计、AdMob 合规 |
| **生产加固** | 多环境配置、StoreKit 测试、CI 钩子、预检检查、事件目录、单元测试骨架、商业打包模板 |
| **调试** | 调试面板、环境调试、广告调试、推送调试、AI 调试等 |

## 快速开始

### 前置条件

- Xcode 15+
- macOS Sonoma+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)（项目文件生成器）

### 初始化项目

```bash
# 1. 安装 XcodeGen
brew install xcodegen

# 2. 运行初始化脚本
./setup.sh \
  --app-name "你的应用名" \
  --bundle-id "com.yourcompany.yourapp" \
  --accent "#B8FF2C"

# 3. 运行验证
python3 Scripts/ycstarter.py validate

# 4. 生成 Xcode 项目文件
xcodegen generate

# 5. 打开项目
open YCAppStarter.xcodeproj
```

**另一种方式** — 使用统一的 CLI：

```bash
python3 Scripts/ycstarter.py init \
  --app-name "我的应用" \
  --bundle-id com.company.myapp \
  --app-group group.com.company.myapp \
  --url-scheme myapp

python3 Scripts/ycstarter.py validate --strict
```

### 配置商业 SDK

- **RevenueCat**：在 `AppSecrets.revenueCatAPIKey` 中填写 API Key
- **Firebase**：将 `GoogleService-Info.plist` 放入 `Sources/YCAppStarter/Resources/`
- **Remote Config**：更新 `RemoteConfigDefaults.json`，在 Firebase 控制台同步键值

### 常用 CLI 命令

| 命令 | 说明 |
|------|------|
| `python3 Scripts/ycstarter.py validate` | 运行全套验证（Remote Config、Deep Links、Widget、StoreKit 等） |
| `python3 Scripts/ycstarter.py doctor` | 运行项目健康检查 |
| `python3 Scripts/ycstarter.py preflight` | App Store 发布前预检 |
| `python3 Scripts/ycstarter.py storekit` | 验证 StoreKit 配置 |
| `python3 Scripts/ycstarter.py ci` | CI 环境验证 |
| `python3 Scripts/ycstarter.py new-plugin <名称> --feature <功能> --category <分类>` | 生成新插件骨架 |

### 发布前检查

```bash
python3 Scripts/validate_production.py
python3 Scripts/appstore_preflight.py
python3 Scripts/validate_storekit.py
```

### 功能开关

所有功能通过 `FeatureFlags.swift` 中的 `AppFeature` 枚举控制。默认启用了一组常用功能（内购、分析、推送、登录、Widget 等），你可以在 `FeatureFlags.default` 中按需增删：

```swift
// Sources/YCAppStarter/Config/FeatureFlags.swift
static let `default` = FeatureFlags(enabledFeatures: [
    .onboarding,
    .paywall,
    .analytics,
    .crashlytics,
    // 添加或移除功能...
])
```

## 项目结构

```
YCAppStarter/
├── Sources/
│   └── YCAppStarter/
│       ├── App/              # App 入口与生命周期
│       ├── Config/           # App 配置、功能开关、密钥
│       ├── Core/             # 核心协议、服务抽象（DI、分析、推送等）
│       ├── Plugins/          # 所有功能插件的实现
│       │   ├── Analytics/    # 分析插件
│       │   ├── Purchase/     # 内购插件
│       │   ├── Firebase/     # Firebase 插件
│       │   ├── SupabaseAuth/ # 登录认证
│       │   ├── Push/         # 推送通知
│       │   ├── AIProxy/      # AI 代理
│       │   └── ...           # 其他插件
│       ├── Modules/          # SwiftUI 界面
│       └── Resources/        # 资源文件
├── Tests/                    # 单元测试
├── Scripts/                  # CLI 工具（初始化、验证等）
├── Config/                   # Xcode 环境配置（xcconfig）
├── Docs/                     # 文档
├── Backend/                  # 后端代码（Supabase Edge Functions 等）
├── Supabase/                 # Supabase 配置
├── StoreKit/                 # StoreKit 测试配置
├── Commercial/               # 商业模板（合同、交付清单等）
└── Metadata/                 # App Store 元数据
```

## 插件架构

每个插件是一个独立目录，遵循统一的生命周期协议：

1. **注册**：在 `PluginCatalog.swift` 中注册
2. **初始化**：插件在 App 启动时按需加载
3. **健康检查**：通过 `PluginDoctor` 验证插件状态
4. **贡献 UI**：插件可向主页、设置页、调试面板贡献界面入口

创建新插件：

```bash
python3 Scripts/ycstarter.py new-plugin "MyFeature" --feature myFeature --category growth
```

## V3.1 生产稳定化

V3.1 聚焦于生产就绪而非新功能，包括：
- 统一 CLI（`ycstarter.py`）
- 多环境配置（Development / Staging / Production）
- StoreKit 测试支持
- CI 验证钩子
- App Store 发布预检

## 版本

当前版本：`3.1.0`

详细变更见 [CHANGELOG.md](./CHANGELOG.md)。
