//
//  SparkTag.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

public struct SparkTag: View {
    @Environment(\.sparkConfig) private var config
    @Environment(\.sparkSize) private var envSize
    
    // 状态控制：悬停效果
    @State private var isHoveringClose = false
    
    let text: String
    let type: SparkType // 修正：使用全局 SparkType 替代 SparkButton 引用
    let effect: SparkEffect
    let isRound: Bool
    let onClose: (() -> Void)?
    
    public init(
        _ text: String,
        type: SparkType = .primary,
        effect: SparkEffect = .light,
        isRound: Bool = false,
        onClose: (() -> Void)? = nil
    ) {
        self.text = text
        self.type = type
        self.effect = effect
        self.isRound = isRound
        self.onClose = onClose
    }

    public var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(fontSize)
                .lineLimit(1)
            
            if let onClose = onClose {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .padding(3)
                        .background(
                            Circle()
                                .fill(getTextColor().opacity(0.15))
                                .opacity(isHoveringClose ? 1 : 0)
                        )
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHoveringClose = hovering
                    }
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .foregroundColor(getTextColor())
        .background(
            ZStack {
                // 修正：直接在背景中使用 ViewBuilder 渲染形状
                renderBackground()
                renderStroke()
            }
        )
        .fixedSize(horizontal: true, vertical: true)
    }

    // --- 渲染辅助方法：解决 Shape 协议不一致问题 ---
    
    @ViewBuilder
    private func renderBackground() -> some View {
        if isRound {
            Capsule().fill(getBgColor())
        } else {
            RoundedRectangle(cornerRadius: 4).fill(getBgColor())
        }
    }
    
    @ViewBuilder
    private func renderStroke() -> some View {
        if isRound {
            Capsule().stroke(getBorderColor(), lineWidth: 1)
        } else {
            RoundedRectangle(cornerRadius: 4).stroke(getBorderColor(), lineWidth: 1)
        }
    }

    // --- 颜色计算逻辑 ---
    
    private func getBgColor() -> Color {
        let base = getBaseColor()
        switch effect {
        case .dark: return base
        case .light: return base.opacity(0.12)
        case .plain: return .clear
        }
    }

    private func getBorderColor() -> Color {
        let base = getBaseColor()
        switch effect {
        case .dark: return base
        case .light, .plain: return base.opacity(0.25)
        }
    }

    private func getTextColor() -> Color {
        switch effect {
        case .dark: return .white
        default: return getBaseColor()
        }
    }

    private func getBaseColor() -> Color {
        switch type {
        case .primary: return config.primaryColor
        case .success: return config.successColor
        case .warning: return config.warningColor
        case .danger: return config.dangerColor
        case .info: return config.infoColor
        case .default: return .gray
        }
    }

    // --- 尺寸适配 ---
    
    private var fontSize: Font {
        switch envSize {
        case .large: return .footnote
        case .mini: return .system(size: 10)
        default: return .caption
        }
    }

    private var horizontalPadding: CGFloat {
        switch envSize {
        case .large: return 12
        case .mini: return 6
        default: return 8
        }
    }

    private var verticalPadding: CGFloat {
        switch envSize {
        case .large: return 6
        case .mini: return 2
        default: return 4
        }
    }
}
