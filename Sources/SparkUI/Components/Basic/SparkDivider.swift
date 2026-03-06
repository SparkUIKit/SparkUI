//
//  SparkDivider.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

public struct SparkDivider: View {
    public enum DividerPosition: Sendable {
        case left, center, right
    }
    
    let label: String?
    let position: DividerPosition
    let isVertical: Bool
    
    public init(
        _ label: String? = nil,
        position: DividerPosition = .center,
        isVertical: Bool = false
    ) {
        self.label = label
        self.position = position
        self.isVertical = isVertical
    }
    
    public var body: some View {
        if isVertical {
            // 垂直分割线
            Divider()
                .frame(width: 1)
                .padding(.horizontal, 8)
        } else {
            // 水平分割线（带文字支持）
            HStack(spacing: 0) {
                if let label = label {
                    lineWithLabel(label)
                } else {
                    line
                }
            }
        }
    }
    
    @ViewBuilder
    private func lineWithLabel(_ text: String) -> some View {
        HStack(spacing: 0) {
            if position == .left {
                line.frame(width: 20)
            } else {
                line
            }
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
            
            if position == .right {
                line.frame(width: 20)
            } else {
                line
            }
        }
    }
    
    private var line: some View {
        Divider()
            .overlay(Color.primary.opacity(0.1))
    }
}

// --- 预览演示 ---

#Preview {
    VStack(spacing: 30) {
        // 1. 基础分割线
        SparkDivider()
        
        // 2. 文字居中
        SparkDivider("数据统计")
        
        // 3. 文字靠左
        SparkDivider("主要内容", position: .left)
        
        // 4. 垂直模式
        HStack {
            Text("编辑")
            SparkDivider(isVertical: true)
            Text("保存")
            SparkDivider(isVertical: true)
            Text("删除")
                .foregroundColor(.red)
        }
        .font(.subheadline)
        
        // 5. 在卡片中使用
        SparkCard(title: "设置面板") {
            VStack(alignment: .leading, spacing: 15) {
                Text("常规设置")
                SparkDivider("高级选项", position: .left)
                Text("安全设置")
            }
        }
    }
    .padding()
}
