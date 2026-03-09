//
//  SparkCard.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

public struct SparkCard<Content: View>: View {
    @Environment(\.sparkConfig) private var config
    
    // 属性定义
    let title: String?
    let type: SparkType        // 新增：支持语义化类型 (.success, .danger 等)
    let shadow: Bool
    let content: Content
    
    public init(
        title: String? = nil,
        type: SparkType = .default, // 默认为常规白底
        shadow: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.type = type
        self.shadow = shadow
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header 部分
            if let title = title {
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        // 如果有 type，标题颜色也随之变浅
                        .foregroundColor(type == .default ? .primary.opacity(0.8) : config.color(for: type))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    
                    Divider()
                }
            }
            
            // Body 部分
            VStack(alignment: .leading) {
                content
            }
            .padding(16)
        }
        // 背景色处理：如果是 default 则纯白，否则使用淡色背景 (对标 Element Plus Light 模式)
        .background(type == .default ? Color(white: 1) : config.color(for: type).opacity(0.05))
        .cornerRadius(config.cornerRadius)
        // 阴影处理
        .shadow(
            color: shadow ? Color.black.opacity(0.05) : Color.clear,
            radius: 10, x: 0, y: 2
        )
        // 边框处理：如果是语义色，则描边也变色
        .overlay(
            RoundedRectangle(cornerRadius: config.cornerRadius)
                .stroke(type == .default ? Color.primary.opacity(0.06) : config.color(for: type).opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview("SparkUI 综合实战") {
    ScrollView {
        VStack(spacing: 24) {
            // 1. 使用 SparkSpace 管理间距
            SparkSpace(.vertical) {
                
                // 场景 A：成功状态卡片
                SparkCard(title: "支付详情", type: .success) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("您的订单已成功支付 ¥299.00")
                            .font(.subheadline)
                    }
                }
                
                // 场景 B：危险状态卡片 (栅格排列示例)
                SparkRow(gutter: 12) {
                    SparkCol(span: 12) {
                        SparkCard(title: "CPU 告警", type: .danger, shadow: false) {
                            Text("负载 98%").bold().foregroundColor(.red)
                        }
                    }
                    SparkCol(span: 12) {
                        SparkCard(title: "内存状态", type: .warning) {
                            Text("占用 75%").foregroundColor(.orange)
                        }
                    }
                }
                
                // 场景 C：常规业务卡片
                SparkCard(title: "用户信息") {
                    SparkSpace(.horizontal) {
                        SparkTag("管理员", type: .primary)
                        SparkTag("在线", type: .success, effect: .plain)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05).ignoresSafeArea())
    }
}
