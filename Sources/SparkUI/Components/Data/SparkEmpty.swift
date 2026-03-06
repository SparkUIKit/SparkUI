//
//  SparkEmpty.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

public struct SparkEmpty<Extra: View>: View {
    @Environment(\.sparkConfig) private var config
    
    private let image: String
    private let description: String
    private let imageSize: CGFloat
    private let extra: Extra?
    
    public init(
        image: String = "tray",
        description: String = "暂无数据",
        imageSize: CGFloat = 80,
        @ViewBuilder extra: () -> Extra? = { nil }
    ) {
        self.image = image
        self.description = description
        self.imageSize = imageSize
        self.extra = extra()
    }

    public var body: some View {
        VStack(spacing: 20) {
            // 1. 图标/插画部分
            Image(systemName: image)
                .font(.system(size: imageSize))
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(config.primaryColor.opacity(0.5))
            
            // 2. 文本描述
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            // 3. 额外操作区域 (如：重新加载按钮)
            if let extra = extra {
                extra
                    .padding(.top, 10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// 为了支持不带 extra 的简易调用
extension SparkEmpty where Extra == EmptyView {
    public init(
        image: String = "tray",
        description: String = "暂无数据",
        imageSize: CGFloat = 80
    ) {
        self.image = image
        self.description = description
        self.imageSize = imageSize
        self.extra = nil
    }
}

#Preview {
    VStack {
        // 场景 1：基础空状态
        SparkEmpty()
            .frame(height: 200)
            .border(Color.gray.opacity(0.1))
        
        // 场景 2：搜索无结果
        SparkEmpty(
            image: "magnifyingglass",
            description: "搜索无结果，换个关键词试试"
        )
        .frame(height: 200)
        
        // 场景 3：带操作按钮 (使用 Card 包裹)
        SparkCard(title: "我的订单") {
            SparkEmpty(
                image: "doc.text.magnifyingglass",
                description: "您还没有相关的订单记录"
            ) {
                Button(action: {}) {
                    Label("去购物", systemImage: "cart")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }
        }
    }
    .padding()
}
