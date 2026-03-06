//
//  SparkCollapse.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

public struct SparkCollapse<Content: View>: View {
    @Environment(\.sparkConfig) private var config
    @Environment(\.sparkSize) private var envSize
    
    private let title: String
    @Binding private var isExpanded: Bool
    private let content: Content
    private let disabled: Bool
    
    public init(
        _ title: String,
        isExpanded: Binding<Bool>,
        disabled: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self._isExpanded = isExpanded
        self.disabled = disabled
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 0) {
            // --- 标题栏 ---
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(title)
                        .font(titleFont)
                        .fontWeight(.medium)
                        .foregroundColor(disabled ? .secondary : .primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary.opacity(0.8))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .background(getBackgroundColor())
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(disabled)
            
            // --- 内容区域 ---
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    Divider()
                        .padding(.horizontal, horizontalPadding)
                    
                    content
                        .padding(horizontalPadding)
                        .padding(.vertical, verticalPadding) // 增加上下边距让内容不局促
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.secondary.opacity(0.03))
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
            }
        }
        .background(getBackgroundColor())
        .cornerRadius(config.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: config.cornerRadius)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
        .clipped()
    }
    
    private func getBackgroundColor() -> Color {
        #if os(iOS)
        return Color(UIColor.systemBackground)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }

    private var titleFont: Font {
        switch envSize {
        case .large: return .body
        case .medium: return .subheadline
        case .small: return .footnote
        case .mini: return .caption
        }
    }
    
    private var verticalPadding: CGFloat {
        switch envSize {
        case .large: return 14
        case .medium: return 12
        case .small: return 10
        case .mini: return 8
        }
    }
    
    private var horizontalPadding: CGFloat {
        envSize == .large ? 16 : 12
    }
}

#Preview {
    // 使用包装视图确保类型推断清晰
    VStack {
        CollapsePreviewContainer()
    }
}

struct CollapsePreviewContainer: View {
    @State private var expand1 = true
    @State private var expand2 = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("SparkCollapse 展示").font(.headline)
                
                // 1. 基础用法
                SparkCollapse("基础面板", isExpanded: $expand1) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("这是折叠面板的内容区域。")
                        Text("支持任何 SwiftUI 视图。").font(.caption).foregroundColor(.secondary)
                    }
                }
                
                // 2. 嵌套复杂内容
                SparkCollapse("配置选项", isExpanded: $expand2) {
                    VStack(spacing: 12) {
                        Toggle("自动更新", isOn: .constant(true))
                        Divider()
                        HStack {
                            Text("当前版本")
                            Spacer()
                            Text("v1.0.2").foregroundColor(.secondary)
                        }
                    }
                }
                
                // 3. 不同尺寸 (显式指定空闭包)
                SparkCollapse("Small Size", isExpanded: .constant(false)) {
                    Text("内容")
                }
                .environment(\.sparkSize, .small)
                
                // 4. 禁用状态
                SparkCollapse("禁用面板", isExpanded: .constant(false), disabled: true) {
                    EmptyView()
                }
            }
            .padding()
        }
        .background(Color.gray.opacity(0.05))
    }
}
