//
//  SparkContainer.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/9.
//

import SwiftUI

// MARK: - 1. 布局上下文 (Environment)
// 用于在组件树中向下传递折叠状态，避免 Aside 显式传参
private struct SparkCollapseKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var isSparkAsideCollapsed: Bool {
        get { self[SparkCollapseKey.self] }
        set { self[SparkCollapseKey.self] = newValue }
    }
}

// MARK: - 2. 外层容器封装
public struct SparkContainer<Content: View>: View {
    @Binding var isCollapsed: Bool
    let content: Content
    
    /// 初始化 SparkUI 容器
    /// - Parameters:
    ///   - isCollapsed: 绑定侧边栏折叠状态
    ///   - content: 包含 Header, Aside, Main, Footer 的闭包
    public init(isCollapsed: Binding<Bool> = .constant(false), @ViewBuilder content: () -> Content) {
        self._isCollapsed = isCollapsed
        self.content = content()
    }
    
    public var body: some View {
        // 使用 GeometryReader 确保容器获取父级全量空间，防止内容坍缩
        GeometryReader { _ in
            VStack(spacing: 0) {
                content
            }
        }
        .environment(\.isSparkAsideCollapsed, isCollapsed)
        // 建议在 macOS 看板应用中开启，让 Header/Footer 延伸到边缘
        .ignoresSafeArea(.container, edges: .all)
    }
}


// MARK: - 4. 预览与实战演示
struct SparkContainer_Previews: PreviewProvider {
    static var previews: some View {
        ContainerExample()
            .frame(width: 900, height: 600)
    }
}

private struct ContainerExample: View {
    @State private var isCollapsed = false
    
    var body: some View {
        SparkContainer(isCollapsed: $isCollapsed) {
            // 1. 顶栏：系统标题与控制按钮
            HeaderView(isCollapsed: $isCollapsed)
            
            // 2. 主体：侧边栏 + 内容区
            HStack(alignment: .top, spacing: 0) {
                SidebarView(isCollapsed: isCollapsed)
                
                Divider()
                
                MainContentView()
            }
            .frame(maxHeight: .infinity)
            
            // 3. 底栏：版权信息
            FooterView()
        }
    }
}

// MARK: - 抽离的子视图 (Subviews)

private struct HeaderView: View {
    @Binding var isCollapsed: Bool
    
    var body: some View {
        SparkHeader(height: 50) {
            HStack {
                Button(action: { withAnimation { isCollapsed.toggle() } }) {
                    SparkIcon(systemName: isCollapsed ? "sidebar.right" : "sidebar.left", size: 18)
                }
                .buttonStyle(.plain)
                .padding(.leading)
                
                Text("浙江省能源综合管理平台")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .background(Color.blue.opacity(0.05))
        }
    }
}

private struct SidebarView: View {
    let isCollapsed: Bool
    
    var body: some View {
        SparkAside(width: 200, collapsedWidth: 64) {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    MenuItem(icon: "gauge.with.needle", title: "仪表中心", isCollapsed: isCollapsed)
                    MenuItem(icon: "leaf.fill", title: "绿证核验", color: .green, isCollapsed: isCollapsed)
                    MenuItem(icon: "chart.pie.fill", title: "能耗统计", color: .orange, isCollapsed: isCollapsed)
                    MenuItem(icon: "gearshape.fill", title: "系统设置", isCollapsed: isCollapsed)
                }
                .padding(.horizontal, 20)
                Spacer()
            }
            .padding(.top, 25)
        }
    }
}

private struct MenuItem: View {
    let icon: String
    let title: String
    var color: Color = .primary
    let isCollapsed: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            SparkIcon(systemName: icon, size: 20, color: color)
                .frame(width: 24)
            if !isCollapsed {
                Text(title)
                    .font(.system(size: 14))
                    .transition(.opacity)
            }
        }
    }
}

private struct MainContentView: View {
    var body: some View {
        SparkMain {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("实时负荷监控").font(.title3).bold()
                    
                    // 业务卡片占位
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.05))
                        .frame(height: 260)
                        .overlay(Text("SparkChart 数据加载中...").foregroundColor(.blue))
                }
                .padding()
            }
        }
    }
}

private struct FooterView: View {
    var body: some View {
        SparkFooter(height: 30) {
            Text("浙ICP备xxxxxxxx号 | © 2026 SparkUI")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
    }
}
