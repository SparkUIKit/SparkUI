//
//  SparkCard.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

public struct SparkCard<Content: View>: View {
    @Environment(\.sparkConfig) private var config
    
    let title: String?
    let shadow: Bool
    let content: Content
    
    public init(
        title: String? = nil,
        shadow: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.shadow = shadow
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header 部分：带有一条优雅的分割线
            if let title = title {
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary.opacity(0.8))
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
        .background(Color(white: 1)) // 纯白底色
        .cornerRadius(config.cornerRadius)
        // Element Plus 风格微阴影：y 轴偏移 2，半径 10，非常淡
        .shadow(
            color: shadow ? Color.black.opacity(0.05) : Color.clear,
            radius: 10, x: 0, y: 2
        )
        // 极淡的外边框，提升精致感
        .overlay(
            RoundedRectangle(cornerRadius: config.cornerRadius)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}

// --- 预览：展示组件库的组合威力 ---

#Preview {
    ZStack {
        Color.gray.opacity(0.05).ignoresSafeArea() // 背景底色
        
        VStack(spacing: 20) {
            // 场景 1：系统状态卡片
            SparkCard(title: "系统监控") {
                VStack(spacing: 15) {
                    SparkAlert(title: "服务器负载正常", type: .success)
                    
                    HStack {
                        SparkTag("主节点", type: .primary)
                        SparkTag("运行中", type: .success, effect: .plain)
                        Spacer()
                    }
                }
            }
            
            // 场景 2：带角标的简单卡片
            SparkCard {
                HStack(spacing: 15) {
                    SparkBadge(value: "9", type: .danger) {
                        Image(systemName: "bell.badge.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                    Text("您有新的未处理预警信息")
                        .font(.subheadline)
                    Spacer()
                }
            }
        }
        .padding()
        .frame(maxWidth: 450)
    }
}

