# SparkUI ⚡️

**SparkUI** 是一款专为Apple生态开发(Swift)、工业级 AI 应用、跨端平台开发及复杂数据监控场景设计的 SwiftUI 组件库。它源自工作实践，旨在解决工业看板中高频出现的实时数据联动、语义化状态预警及多端布局适配问题。

---

## 📖 目录

* [🌟 特性](https://www.google.com/search?q=%23-%E7%89%B9%E6%80%A7)
* [🏗 设计理念](https://www.google.com/search?q=%23-%E8%AE%BE%E8%AE%A1%E7%90%86%E5%BF%B5)
* [📦 安装](https://www.google.com/search?q=%23-%E5%AE%89%E8%A3%85-swift-package-manager)
* [🚀 快速上手](https://www.google.com/search?q=%23-%E5%BF%AB%E9%80%9F%E4%B8%8A%E6%89%8B)
* [🎨 核心体系](https://www.google.com/search?q=%23-%E6%A0%B8%E5%BF%83%E4%BD%93%E7%B3%BB)
* [📚 组件概览](https://www.google.com/search?q=%23-%E7%BB%84%E4%BB%B6%E6%A6%82%E8%A7%88-component-overview)
* [🛠 进阶：自定义主题](https://www.google.com/search?q=%23-%E8%BF%9B%E9%98%B6%E8%87%AA%E5%AE%9A%E4%B9%89%E4%B8%BB%E9%A2%98)
* [🤝 参与贡献](https://www.google.com/search?q=%23-%E5%8F%82%E4%B8%8E%E8%B4%A1%E7%8C%AE)
* [📄 开源协议](https://www.google.com/search?q=%23-%E5%BC%80%E6%BA%90%E5%8D%8F%E8%AE%AE)

---

## 🌟 特性

* 🏗 **架构优先**: 基于 `EnvironmentValues` 注入机制，支持从根节点到叶子节点的一键样式穿透。
* 🎨 **工业语义**: 深度封装 `Primary` (主控), `Success` (在线/正常), `Warning` (过载/预警), `Danger` (故障/离线) 等业务状态。
* 📈 **高性能监控**: 专为高频刷新的能源数据优化，内置 `SparkRollingNumber` 数字滚动算法。
* 🛠 **类型安全**: 严格适配 Swift 6 并发模型，支持 `@MainActor` 隔离，消除数据竞争风险。
* 🌑 **全自动适配**: 像素级适配深色模式，特别优化低光照工业生产环境下的视觉舒适度。

---

## 🏗 设计理念

`SparkUI` 的核心逻辑是 **"State as Style" (状态即风格)**。在能源管理领域，颜色的意义远大于审美。

* **一致性**: 无论是在 Huzhou 的大屏还是 Ningbo 的移动端，同一业务含义的组件表现高度一致。
* **低耦合**: 组件不直接依赖特定的业务模型，通过通用的 `Double` 或 `String` 接口进行驱动。

---

## 📦 安装 (Swift Package Manager)

1. 在 Xcode 项目中选择 **File > Add Packages...**
2. 输入仓库地址：`https://github.com/SparkUIKit/SparkUI.git`
3. 依赖选择 `v0.1.0` 或更高版本。

---

## 🚀 快速上手

### 1. 挂载全局环境

在应用入口注入 `SparkUI` 核心配置和消息容器。

```swift
import SwiftUI
import SparkUI

@main
struct SparkApp: App {
    var body: some Scene {
        WindowGroup {
            // 业务视图根节点
            ContentView()
                .sparkConfig(SparkConfig()) // 全局配置注入
                .overlay {
                    SparkMessageContainer() // 必须挂载消息容器
                }
        }
    }
}

```

### 2. 构建监控面板

使用 `SparkStatCard` 快速搭建数据看板。

```swift
import SwiftUI
import SparkUI

struct DashboardView: View {
    @State private var powerLoad: Double = 421.5
    
    var body: some View {
        ScrollView {
            SparkSpace(direction: .vertical) {
                // 实时负荷卡片
                SparkStatCard(
                    title: "实时用电负荷",
                    value: powerLoad,
                    unit: "MW",
                    trend: 0.15,
                    type: .primary
                )
                
                // 设备状态标签
                HStack {
                    Text("网关状态：")
                    SparkTag("在线", type: .success, effect: .light)
                }
            }
            .padding()
        }
    }
}

```

---

## 📚 组件概览 (Component Overview)

| 分类 | 已实现组件 | 功能亮点 |
| --- | --- | --- |
| **基础与布局** | `SparkButton`, `SparkDivider`, `SparkSpace`, `SparkGrid` | 响应式栅格，自动间距缩进 |
| **数据监控** | `SparkStatCard`, `SparkRollingNumber`, `SparkCard` | **数字插值动画**，工业看板风格 |
| **状态标记** | `SparkTag`, `SparkBadge`, `SparkAvatar`, `SparkEmpty` | 语义化视觉深度 (`Dark/Light/Plain`) |
| **交互输入** | `SparkInput`, `SparkSwitch`, `SparkSlider`, `SparkStepper` | 增强型 Form 控件，支持前后缀注入 |
| **反馈提醒** | `SparkMessage`, `SparkToast`, `SparkAlert`, `SparkLoading` | 全局单例管理，异步消息队列 |
| **可视化辅助** | `SparkProgress`, `SparkCircleProgress`, `SparkSkeleton` | 碳中和完成率专用仪表盘逻辑 |

---

### 📊 SparkCharts 兼容性说明
| 图表类型 | 最低系统要求 | 说明 |
| :--- | :--- | :--- |
| 折线图 (Line) | iOS 16 / macOS 13 | 核心能源趋势渲染 |
| 柱状图 (Bar) | iOS 16 / macOS 13 | 能耗分布对比 |
| 饼图 (Pie) | **iOS 17 / macOS 14** | 需要最新系统支持 `SectorMark` |
---

## 🛠 进阶：自定义主题

你可以定义一套符合企业识别系统 (VI) 的配置对象。例如，为某市级平台定制“生态绿”主题：

```swift
extension SparkConfig {
    static var ecoGreen: SparkConfig {
        var config = SparkConfig()
        config.primaryColor = Color(hex: "#10B981")
        config.cornerRadius = 20
        config.spacingMedium = 16
        return config
    }
}

// 在视图层级应用
ContentView().sparkConfig(.ecoGreen)

```

---

## 🤝 参与共创 (Contributing)

欢迎任何形式的贡献！无论是修复 Bug、提出新功能建议，还是改进文档。

### 申请流程
1. **Fork** 本项目到你的仓库。
2. 在你的仓库中创建一个新的功能分支 (`feature/your-feature`)。
3. 提交你的代码更改。
4. 发起一个 **Pull Request** 指向本仓库的 `release/v0.1` 分支。

### 联系作者
如果你有深度的合作意向或想加入核心贡献者名单，请通过邮件与我联系：
📩 **Email**: [kaijie0318@foxmail.com](mailto:kaijie0318@foxmail.com)

请在邮件主题中注明：`[SparkUI 贡献申请] - 你的 GitHub ID - 合作意向`

---

## 👨‍💻 作者 (Author)

**Zhang Kaijie (张凯杰)**
* 🚀 **专长**: 工业级 AI 应用、能源可视化看板、SwiftUI 跨平台开发
* 💬 **交流**: 如果你有关于 `SparkUI` 的建议，或者有项目的技术咨询：
  * **WeChat**: `Auto-318` 
  * **GitHub**: [@SparkUIKit](https://github.com/SparkUIKit)

### ☕️ 赞赏与支持 (Donate)

如果你觉得本项目对你有帮助，欢迎请作者喝杯咖啡：

| 微信联系我 | 扫码支持作者 |
| :---: | :---: |
| <img src="Assets/wechat_qr.jpg" width="160px" /> | <img src="Assets/donate_qr.jpg" width="160px" /> |

---

## 📄 开源协议 (License)

本项目基于 **MIT** 协议开源 - 允许商业使用、修改及再发布。查看 [LICENSE](LICENSE) 文件了解详细信息。
