//
//  SparkButton.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

public struct SparkButton: View {
    @Environment(\.sparkConfig) private var config
    @Environment(\.sparkSize) private var envSize
    
    // 基础属性
    private let title: String
    private let type: SparkType
    private let manualSize: SparkSize?
    private let icon: String?
    private let isAfterIcon: Bool
    
    // 状态属性
    private let loading: Bool
    private let disabled: Bool
    private let action: () -> Void
    
    public init(
        _ title: String,
        type: SparkType = .primary,
        size: SparkSize? = nil,
        icon: String? = nil,
        isAfterIcon: Bool = false,
        loading: Bool = false,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.type = type
        self.manualSize = size
        self.icon = icon
        self.isAfterIcon = isAfterIcon
        self.loading = loading
        self.disabled = disabled
        self.action = action
    }

    private var currentSize: SparkSize { manualSize ?? envSize }

    public var body: some View {
        Button(action: {
            if !loading && !disabled {
                action()
            }
        }) {
            HStack(spacing: spacing) {
                if loading {
                    ProgressView()
                        .scaleEffect(progressScale)
                        .tint(foregroundColor)
                } else if let iconName = icon, !isAfterIcon {
                    Image(systemName: iconName)
                }
                
                Text(title)
                    .font(font)
                    .fontWeight(.medium)
                
                if !loading, let iconName = icon, isAfterIcon {
                    Image(systemName: iconName)
                }
            }
            .frame(minWidth: minWidth)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(config.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: config.cornerRadius)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(disabled || loading)
        .opacity(disabled || loading ? 0.6 : 1.0)
    }

    // MARK: - 样式计算
    
    private var backgroundColor: Color {
        if type == .default { return Color.white }
        return colorForType
    }
    
    private var foregroundColor: Color {
        if type == .default { return config.primaryColor }
        return .white
    }
    
    private var borderColor: Color {
        if type == .default { return Color.gray.opacity(0.3) }
        return colorForType
    }
    
    private var colorForType: Color {
        switch type {
        case .primary: return config.primaryColor
        case .success: return config.successColor
        case .warning: return config.warningColor
        case .danger: return config.dangerColor
        case .default: return .gray
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch currentSize {
        case .large: return 20; case .medium: return 16; case .small: return 12; case .mini: return 8
        }
    }
    
    private var verticalPadding: CGFloat {
        switch currentSize {
        case .large: return 12; case .medium: return 9; case .small: return 6; case .mini: return 4
        }
    }
    
    private var font: Font {
        switch currentSize {
        case .large: return .body; case .medium: return .subheadline; case .small: return .footnote; case .mini: return .caption
        }
    }
    
    private var progressScale: CGFloat {
        currentSize == .large ? 1.0 : 0.8
    }
    
    private var minWidth: CGFloat {
        currentSize == .mini ? 0 : 64
    }
    
    private var spacing: CGFloat { 6 }
}

#Preview {
    ScrollView {
        VStack(spacing: 30) {
            
            GroupBox("按钮类型 (Types)") {
                HStack {
                    SparkButton("主要", type: .primary) {}
                    SparkButton("成功", type: .success) {}
                    SparkButton("危险", type: .danger) {}
                    SparkButton("默认", type: .default) {}
                }
                .padding(.vertical, 10)
            }
            
            GroupBox("尺寸体系 (Sizes)") {
                HStack(alignment: .bottom) {
                    SparkButton("Large", size: .large) {}
                    SparkButton("Medium", size: .medium) {}
                    SparkButton("Small", size: .small) {}
                    SparkButton("Mini", size: .mini) {}
                }
                .padding(.vertical, 10)
            }
            
            GroupBox("图标 & 状态 (Icons & States)") {
                VStack(spacing: 15) {
                    HStack {
                        // 修正点：先写 type，后写 icon
                        SparkButton("搜索", type: .primary, icon: "magnifyingglass") {}
                        SparkButton("下载", type: .success, icon: "arrow.down", isAfterIcon: true) {}
                    }
                    HStack {
                        SparkButton("加载中", type: .primary, loading: true) {}
                        SparkButton("已禁用", type: .warning, disabled: true) {}
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .padding()
    }
    .background(Color.gray.opacity(0.05))
}
