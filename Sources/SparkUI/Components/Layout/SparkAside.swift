//
//  SparkAside.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/9.
//

import SwiftUI

/// 侧边栏容器：支持自动/手动折叠，并能自动填充垂直高度
public struct SparkAside<Content: View>: View {
    // 核心：从环境值中获取父容器传递的折叠状态
    @Environment(\.isSparkAsideCollapsed) private var isCollapsed
    
    public let width: CGFloat
    public let collapsedWidth: CGFloat
    public let content: Content
    
    /// 初始化侧边栏
    /// - Parameters:
    ///   - width: 展开时的宽度 (默认 200)
    ///   - collapsedWidth: 折叠时的宽度 (默认 64)
    ///   - content: 侧边栏内容
    public init(
        width: CGFloat = 200,
        collapsedWidth: CGFloat = 64,
        @ViewBuilder content: () -> Content
    ) {
        self.width = width
        self.collapsedWidth = collapsedWidth
        self.content = content()
    }
    
    public var body: some View {
        content
            // 1. 核心布局：宽度随折叠状态切换
            .frame(width: isCollapsed ? collapsedWidth : width)
            // 2. 垂直撑满：确保背景色延伸到底部
            .frame(maxHeight: .infinity)
            // 3. 背景增强：使用系统层级的背景色，支持深色模式
            .background(Color.gray.opacity(0.05))
            // 4. 防止溢出：折叠过程中如果内容没来得及收缩，强制裁剪
            .clipped()
            // 5. 动画优化：使用弹性动画，符合原生质感
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isCollapsed)
    }
}

// MARK: - 预览 (用于在独立开发 Aside 时进行测试)
struct SparkAside_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 0) {
            // 展开态预览
            SparkAside {
                VStack(spacing: 20) {
                    Label("仪表盘", systemImage: "gauge")
                    Label("统计", systemImage: "chart.bar")
                    Spacer()
                }
                .padding()
            }
            .environment(\.isSparkAsideCollapsed, false)
            
            Divider()
            
            // 折叠态预览
            SparkAside {
                VStack(spacing: 20) {
                    Image(systemName: "gauge")
                    Image(systemName: "chart.bar")
                    Spacer()
                }
                .padding()
            }
            .environment(\.isSparkAsideCollapsed, true)
        }
    }
}
