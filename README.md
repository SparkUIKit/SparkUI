# SparkUI ⚡️

**SparkUI** 是一款专为工业级 AI 应用、能源管理平台及复杂数据监控场景设计的 SwiftUI 组件库。它提供了高度语义化的色彩体系和灵活的布局逻辑，帮助开发者快速构建一致、高效且美观的现代化界面。

## 🌟 特性

* 🏗 **架构优先**: 基于环境值 (EnvironmentValues) 的注入机制，支持一键切换全局样式。
* 🎨 **语义化色彩**: 完备的 `Primary`, `Success`, `Warning`, `Danger`, `Info` 五大核心语义状态。
* 📱 **跨平台支持**: 深度优化 iOS 15+ 与 macOS 12+ 的原生渲染性能。
* 🛠 **类型安全**: 全量支持 Swift 6 并发安全 (`Sendable`)。
* 🌑 **暗黑模式**: 像素级适配深色模式，确保在工业监控环境下具备极佳的阅读舒适度。

## 📦 安装 (Swift Package Manager)

1. 在 Xcode 中打开你的项目，选择 **File > Add Packages...**。
2. 在搜索框中输入你的仓库地址：
`https://github.com/SparkUIKit/SparkUI.git`
3. 选择版本范围或指定分支，点击 **Add Package**。

## 🚀 快速上手

### 1. 配置注入

在应用的入口文件或根容器中挂载全局配置。

```swift
import SwiftUI
import SparkUI

@main
struct SparkApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    // 注入自定义配置（可选）
                    .sparkConfig(SparkConfig())
                
                // 必须在根部挂载消息容器以支持弹窗提醒
                SparkMessageContainer()
            }
        }
    }
}

```

### 2. 使用基础组件

```swift
// 语义化标签
SparkTag("数据正常", type: .success, effect: .light)
    .sparkSize(.small)

// 触发消息提醒
Button("更新配置") {
    SparkMessage.show("配置已同步至浙江能源平台", type: .info)
}

```

---

## 🎨 核心概念

### 语义化体系 (SparkType)

我们不只是定义颜色，而是定义**状态**。

* `.primary`: 品牌主色，用于主要操作。
* `.success`: 运行正常、验证通过、在线状态。
* `.warning`: 负载预警、待定状态。
* `.danger`: 故障报错、离线状态、严重错误。
* `.info`: 中性说明、信息辅助。

### 尺寸逻辑 (SparkSize)

通过 `.sparkSize()` 装饰器，可以统一控制容器及其子组件的比例：
`mini` | `small` | `medium` (默认) | `large`

---

## 🛠 自定义主题

你可以通过重写 `SparkConfig` 来适配特定的品牌视觉需求：

```swift
var customConfig = SparkConfig()
customConfig.primaryColor = Color.purple
customConfig.cornerRadius = 12

// 应用到视图层级
ContentView().sparkConfig(customConfig)

```

---

## 📚 组件概览

| 组件 | 分类 | 说明 |
| --- | --- | --- |
| `SparkTag` | 数据展示 | 语义化标签，支持三种外观模式 (`dark`, `light`, `plain`) |
| `SparkMessage` | 反馈 | 全局顶部通知，支持队列管理 |
| `SparkSpace` | 布局 | 灵活的间距容器，基于尺寸体系自动缩进 |
| `SparkCard` | 数据展示 | 标准工业卡片容器，支持阴影与圆角配置 |

---

## 👨‍💻 作者

Created by **Zhang Kaijie (张凯杰)** - 2026.

---

## 📄 开源协议

本项目基于 **MIT** 协议开源。

---
