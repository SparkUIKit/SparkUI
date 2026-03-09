//
//  SparkMain.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/9.
//

import SwiftUI

/// 主要内容区域容器：自动占据剩余所有空间，并提供标准的对齐逻辑
public struct SparkMain<Content: View>: View {
    public let content: Content
    
    /// 初始化主内容区
    /// - Parameter content: 主内容视图
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            // 核心 1：强制水平和垂直方向都占据最大可用空间
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            // 核心 2：确保背景不会因为内容不满而留白（如果需要设置背景色的话）
            .background(Color(.windowBackgroundColor).opacity(0.1))
    }
}

// MARK: - 预览
struct SparkMain_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 0) {
            // 模拟一个简单的侧边栏作为对比
            Color.gray.opacity(0.1)
                .frame(width: 200)
                .overlay(Text("Aside"))
            
            Divider()
            
            // 主内容区
            SparkMain {
                VStack(alignment: .leading, spacing: 20) {
                    Text("数据看板中心").font(.title).bold()
                    
                    // 模拟之前写的 SparkChart 组件
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                        .frame(height: 200)
                        .overlay(Text("SparkChart 实时负荷曲线"))
                    
                    Spacer()
                }
                .padding()
            }
        }
        .frame(width: 600, height: 400)
    }
}
