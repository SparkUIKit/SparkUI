//
//  SparkAlert.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

public struct SparkAlert: View {
    @Environment(\.sparkConfig) private var config
    
    let title: String
    let description: String?
    let type: SparkType
    let showIcon: Bool
    let closable: Bool
    let onClose: (() -> Void)?
    
    @State private var isVisible: Bool = true
    
    public init(
        title: String,
        description: String? = nil,
        type: SparkType = .primary,
        showIcon: Bool = true,
        closable: Bool = true,
        onClose: (() -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.type = type
        self.showIcon = showIcon
        self.closable = closable
        self.onClose = onClose
    }

    public var body: some View {
        if isVisible {
            HStack(alignment: description == nil ? .center : .top, spacing: 12) {
                // 1. 图标部分
                if showIcon {
                    Image(systemName: iconName)
                        .font(.system(size: description == nil ? 16 : 20))
                        .foregroundColor(baseColor)
                }
                
                // 2. 文字部分
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary.opacity(0.8))
                    
                    if let desc = description {
                        Text(desc)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                Spacer()
                
                // 3. 关闭按钮
                if closable {
                    Button {
                        withAnimation(.spring()) {
                            isVisible = false
                        }
                        onClose?()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: config.cornerRadius)
                    .fill(baseColor.opacity(0.12)) // 统一使用 Light 风格
            )
            .overlay(
                RoundedRectangle(cornerRadius: config.cornerRadius)
                    .stroke(baseColor.opacity(0.2), lineWidth: 1)
            )
            .transition(.asymmetric(insertion: .opacity, removal: .scale(scale: 0.95).combined(with: .opacity)))
        }
    }

    // --- 动态辅助逻辑 ---

    private var baseColor: Color {
        switch type {
        case .primary: return config.primaryColor
        case .success: return config.successColor
        case .warning: return config.warningColor
        case .danger: return config.dangerColor
        case .default: return Color.gray
        }
    }

    private var iconName: String {
        switch type {
        case .primary: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .danger: return "xmark.circle.fill"
        case .default: return "bell.fill"
        }
    }
}

// --- SparkAlert 综合预览 ---

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            // 1. 基础用法：仅标题
            GroupBox("基础类型 (Basic)") {
                VStack(spacing: 12) {
                    SparkAlert(title: "恭喜！您的资料已更新成功", type: .success)
                    SparkAlert(title: "这是一条普通的信息提示", type: .primary)
                    SparkAlert(title: "警告：存储空间即将不足", type: .warning)
                    SparkAlert(title: "错误：服务器连接超时", type: .danger)
                }
                .padding(.vertical, 8)
            }
            
            // 2. 丰富内容：带描述文字
            GroupBox("带辅助文本 (With Description)") {
                SparkAlert(
                    title: "升级成功",
                    description: "SparkUI 已更新至最新版本 2.0。我们优化了底层动画引擎，并新增了 5 个核心组件，快去试试吧！",
                    type: .success
                )
                .padding(.vertical, 8)
            }
            
            // 3. 交互与配置展示
            GroupBox("功能配置 (Configuration)") {
                VStack(spacing: 12) {
                    // 隐藏图标
                    SparkAlert(title: "这是一条不带图标的简洁提示", type: .primary, showIcon: false)
                    
                    // 不可关闭
                    SparkAlert(
                        title: "强制公告",
                        description: "这是一条不可手动关闭的通知，通常用于展示系统维护公告。",
                        type: .warning,
                        closable: false
                    )
                    
                    // 自定义回调
                    SparkAlert(title: "带回调的 Alert", type: .danger) {
                        print("用户点击了关闭按钮")
                    }
                }
                .padding(.vertical, 8)
            }
            
            // 4. 动态显示测试
            AlertTestContainer()
        }
        .padding()
    }
    .background(Color.gray.opacity(0.05))
}

// 内部辅助组件：用于测试关闭后的动态显示逻辑
struct AlertTestContainer: View {
    @State private var showAlert = true
    
    var body: some View {
        VStack {
            if !showAlert {
                Button("重置 Alert 状态") {
                    withAnimation { showAlert = true }
                }
                .font(.caption)
                .buttonStyle(.bordered)
            }
            
            if showAlert {
                SparkAlert(
                    title: "动态 Alert",
                    description: "你可以点击右侧的关闭按钮，观察平滑的收缩动画。",
                    type: .primary
                ) {
                    showAlert = false
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}
