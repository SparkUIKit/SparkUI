//
//  SparkSegmented.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

public struct SparkSegmented: View {
    @Environment(\.sparkConfig) private var config
    @Environment(\.sparkSize) private var envSize
    
    @Binding private var selection: Int
    private let items: [String]
    @Namespace private var activeTab
    
    public init(selection: Binding<Int>, items: [String]) {
        self._selection = selection
        self.items = items
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<items.count, id: \.self) { index in
                segmentedButton(for: index)
            }
        }
        .padding(2)
        .background(Color.secondary.opacity(0.12))
        .cornerRadius(config.cornerRadius)
    }
    
    @ViewBuilder
    private func segmentedButton(for index: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selection = index
            }
        } label: {
            Text(items[index])
                .font(font)
                .fontWeight(selection == index ? .semibold : .regular)
                .foregroundColor(selection == index ? .primary : .secondary)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background {
                    if selection == index {
                        // 修正点：显式指定平台背景色，避免 CGColor 歧义
                        RoundedRectangle(cornerRadius: config.cornerRadius - 2)
                            .fill(adaptiveBackground)
                            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
                            .matchedGeometryEffect(id: "active_rect", in: activeTab)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    // 辅助属性：适配 iOS 和 macOS 的纯白/系统背景
    private var adaptiveBackground: Color {
        #if os(iOS)
        return Color(uiColor: .systemBackground)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }

    private var height: CGFloat {
        switch envSize {
        case .large: return 40
        case .medium: return 32
        case .small: return 28
        case .mini: return 24
        }
    }
    
    private var font: Font {
        switch envSize {
        case .large: return .body
        case .medium: return .subheadline
        case .small: return .footnote
        case .mini: return .caption
        }
    }
}

// MARK: - 预览
#Preview {
    SegmentedPreviewContainer()
}

struct SegmentedPreviewContainer: View {
    @State private var selected1: Int = 0
    @State private var selected2: Int = 1
    
    var body: some View {
        List {
            Section("基础用法") {
                SparkSegmented(selection: $selected1, items: ["最新", "热门", "推荐"])
                    .padding(.vertical, 4)
            }
            
            Section("尺寸体系") {
                SparkSegmented(selection: $selected2, items: ["月度", "年度"])
                    .environment(\.sparkSize, .large)
                
                SparkSegmented(selection: $selected2, items: ["已发货", "待收货", "已评价"])
                    .environment(\.sparkSize, .small)
            }
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #endif
    }
}
