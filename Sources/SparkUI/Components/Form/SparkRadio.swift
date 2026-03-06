//
//  SparkRadio.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

public struct SparkRadio<T: Hashable>: View {
    @Environment(\.sparkConfig) private var config
    @Environment(\.sparkSize) private var envSize
    
    private let value: T
    @Binding private var selection: T
    private let label: String?
    private let disabled: Bool
    
    public init(
        _ value: T,
        selection: Binding<T>,
        label: String? = nil,
        disabled: Bool = false
    ) {
        self.value = value
        self._selection = selection
        self.label = label
        self.disabled = disabled
    }

    private var isSelected: Bool {
        selection == value
    }

    public var body: some View {
        HStack(spacing: labelSpacing) {
            // --- 单选框核心图标 ---
            ZStack {
                Circle()
                    .stroke(borderColor, lineWidth: 1.5)
                    .frame(width: radioSize, height: radioSize)
                
                if isSelected {
                    Circle()
                        .fill(disabled ? Color.gray.opacity(0.4) : config.primaryColor)
                        .frame(width: dotSize, height: dotSize)
                        // 选中时的中心点缩放动画
                        .transition(.scale(scale: 0.5).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
            
            // --- 文本标签 ---
            if let label = label {
                Text(label)
                    .font(fontSize)
                    .foregroundColor(disabled ? .secondary : .primary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !disabled && !isSelected {
                selection = value
            }
        }
        .opacity(disabled ? 0.6 : 1.0)
    }

    // MARK: - 样式计算
    
    private var radioSize: CGFloat {
        switch envSize {
        case .large: return 20
        case .medium: return 16
        case .small: return 14
        case .mini: return 12
        }
    }
    
    private var dotSize: CGFloat {
        radioSize * 0.55 // 中心圆点比例
    }
    
    private var fontSize: Font {
        switch envSize {
        case .large: return .body
        case .medium: return .subheadline
        case .small: return .footnote
        case .mini: return .caption2
        }
    }
    
    private var borderColor: Color {
        if isSelected && !disabled { return config.primaryColor }
        return Color.secondary.opacity(0.4)
    }
    
    private var labelSpacing: CGFloat { 8 }
}

#Preview {
    struct RadioDemo: View {
        @State private var selectedFruit = "Apple"
        @State private var selectedSize: SparkSize = .medium
        
        var body: some View {
            VStack(alignment: .leading, spacing: 30) {
                
                // 1. 基础用法
                GroupBox("水果选择 (Value: \(selectedFruit))") {
                    HStack(spacing: 20) {
                        SparkRadio("Apple", selection: $selectedFruit, label: "苹果")
                        SparkRadio("Banana", selection: $selectedFruit, label: "香蕉")
                        SparkRadio("Orange", selection: $selectedFruit, label: "橙子")
                    }
                    .padding(.vertical, 10)
                }
                
                // 2. 不同尺寸 (环境集成)
                GroupBox("尺寸体系演示") {
                    VStack(alignment: .leading, spacing: 15) {
                        SparkRadio(.large, selection: $selectedSize, label: "Large Size")
                            .environment(\.sparkSize, .large)
                        
                        SparkRadio(.medium, selection: $selectedSize, label: "Medium Size")
                            .environment(\.sparkSize, .medium)
                        
                        SparkRadio(.small, selection: $selectedSize, label: "Small Size")
                            .environment(\.sparkSize, .small)
                        
                        SparkRadio(.mini, selection: $selectedSize, label: "Mini Size")
                            .environment(\.sparkSize, .mini)
                    }
                    .padding(.vertical, 10)
                }
                
                // 3. 禁用状态
                GroupBox("禁用状态展示") {
                    HStack(spacing: 20) {
                        SparkRadio("1", selection: .constant("1"), label: "禁用已选", disabled: true)
                        SparkRadio("2", selection: .constant("1"), label: "禁用未选", disabled: true)
                    }
                    .padding(.vertical, 10)
                }
            }
            .padding()
        }
    }
    return RadioDemo()
}


