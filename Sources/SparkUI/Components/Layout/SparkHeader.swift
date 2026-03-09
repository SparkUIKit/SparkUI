//
//  SparkHeader.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/9.
//

import SwiftUI

public struct SparkHeader<Content: View>: View {
    public let height: CGFloat
    public let content: Content
    
    public init(height: CGFloat = 60, @ViewBuilder content: () -> Content) {
        self.height = height
        self.content = content()
    }
    
    public var body: some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: height)
            // 核心修复：在内容上方增加填充，避开 macOS 信号灯按钮
            // 24 是 macOS 标准标题栏按钮的高度预留
            .padding(.top, 24)
            .zIndex(10)
            .background(Color(.windowBackgroundColor))
    }
}

// MARK: - 预览
struct SparkHeader_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            SparkHeader {
                HStack {
                    Image(systemName: "bolt.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.blue)
                    
                    Text("能源平台管理后台")
                        .font(.headline)
                    
                    Spacer()
                    
                    Image(systemName: "person.crop.circle")
                        .font(.title2)
                }
                .padding(.horizontal)
            }
            
            Divider()
            
            // 下方预览占位
            Color.gray.opacity(0.05)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(Text("Content Area"))
        }
        .frame(width: 600, height: 300)
    }
}
