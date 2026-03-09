//
//  SparkSpace.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/6.
//

import SwiftUI

public struct SparkSpace<Content: View>: View {
    @Environment(\.sparkConfig) private var config
    @Environment(\.sparkSize) private var size
    
    public enum Direction: Sendable {
        case horizontal, vertical
    }
    
    private let direction: Direction
    private let alignment: Alignment
    private let content: Content
    
    public init(
        _ direction: Direction = .horizontal,
        alignment: Alignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.direction = direction
        self.alignment = alignment
        self.content = content()
    }
    
    public var body: some View {
        // 显式调用 size 的方法，确保类型推断链条清晰
        let spacingValue: CGFloat = size.value(in: config)
        
        if direction == .horizontal {
            HStack(alignment: alignment.vertical, spacing: spacingValue) {
                content
            }
        } else {
            VStack(alignment: alignment.horizontal, spacing: spacingValue) {
                content
            }
        }
    }
}

// MARK: - 解决推断问题的预览
#Preview("SparkSpace 演示") {
    VStack(spacing: 40) {
        // 显式指定枚举类型以防编译器推断失败
        SparkSpace(.horizontal) {
            // 确保你的 SparkTag 接受的是 SparkType
            SparkTag("标签", type: SparkType.primary)
            SparkTag("成功", type: SparkType.success)
        }
        .sparkSize(.large)
        
        SparkSpace(.vertical, alignment: .leading) {
            // 确保 SparkCard 这里的 type 声明正确
            SparkCard(type: SparkType.danger) {
                Text("警告卡片内容")
            }
        }
    }
    .padding()
}
