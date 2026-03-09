//
//  SparkFooter.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/9.
//

import SwiftUI

/// 底栏容器：提供标准的底部间距和版权/操作区域封装
public struct SparkFooter<Content: View>: View {
    public let height: CGFloat
    public let content: Content
    
    /// 初始化底栏
    /// - Parameters:
    ///   - height: 底栏高度 (默认 40)
    ///   - content: 底栏内容
    public init(height: CGFloat = 40, @ViewBuilder content: () -> Content) {
        self.height = height
        self.content = content()
    }
    
    public var body: some View {
        content
            // 1. 核心布局：宽度撑满，高度固定
            .frame(maxWidth: .infinity)
            .frame(height: height)
            // 2. 视觉增强：通常底栏色调较淡，与主内容区区分开
            .background(Color.gray.opacity(0.05))
            // 3. 语义化对齐：默认居中，符合 Web 底部规范
            .multilineTextAlignment(.center)
    }
}

// MARK: - 预览
struct SparkFooter_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            SparkFooter {
                Text("Copyright © 2026 SparkUI. 保留所有权利。")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 400, height: 200)
    }
}
