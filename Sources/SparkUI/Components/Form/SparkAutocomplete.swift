//
//  SparkAutocomplete.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/9.
//

import SwiftUI

/// 自动补全输入框：支持动态高度建议列表与宽度对齐
public struct SparkAutocomplete: View {
    @Binding var text: String
    public var placeholder: String
    public var prefixIcon: String?
    public var suggestions: [String]
    public var onSelect: ((String) -> Void)?
    
    @State private var isShowingPopover: Bool = false
    
    public init(
        text: Binding<String>,
        placeholder: String = "请输入",
        prefixIcon: String? = nil,
        suggestions: [String],
        onSelect: ((String) -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.prefixIcon = prefixIcon
        self.suggestions = suggestions
        self.onSelect = onSelect
    }
    
    private var filteredSuggestions: [String] {
        if text.isEmpty { return [] }
        // 过滤逻辑：不区分大小写包含，且排除完全匹配的情况（已选完）
        return suggestions.filter {
            $0.localizedCaseInsensitiveContains(text) && $0 != text
        }
    }
    
    public var body: some View {
        // 使用 GeometryReader 动态获取输入框容器的宽度和位置
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                SparkInput(
                    text: $text,
                    placeholder: placeholder,
                    prefixIcon: prefixIcon
                )
                .onChange(of: text) { newValue in
                    withAnimation(.spring(response: 0.3)) {
                        isShowingPopover = !filteredSuggestions.isEmpty
                    }
                }
            }
            .overlay(alignment: .topLeading) {
                if isShowingPopover {
                    SuggestionListView(
                        items: filteredSuggestions,
                        width: geometry.size.width,
                        action: { selected in
                            text = selected
                            isShowingPopover = false
                            onSelect?(selected)
                        }
                    )
                    // 动态偏移：刚好处于输入框正下方（加上 5pt 间距）
                    .offset(y: geometry.size.height + 5)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        // 必须锁定 GeometryReader 的高度，防止其撑开父容器导致布局坍塌
        .frame(height: 36)
        .zIndex(100)
    }
}

// MARK: - 内部私有组件

private struct SuggestionListView: View {
    let items: [String]
    let width: CGFloat
    let action: (String) -> Void
    
    // 配置常量
    private let itemHeight: CGFloat = 38
    private let maxVisibleItems: CGFloat = 8
    
    // 核心逻辑：计算动态高度
    private var dynamicHeight: CGFloat {
        let totalContentHeight = CGFloat(items.count) * itemHeight
        let maxHeight = maxVisibleItems * itemHeight
        return min(totalContentHeight, maxHeight)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(items, id: \.self) { item in
                        SuggestionItem(title: item, height: itemHeight) {
                            action(item)
                        }
                        if item != items.last {
                            Divider().opacity(0.3).padding(.horizontal, 4)
                        }
                    }
                }
            }
        }
        .frame(height: dynamicHeight)
        .frame(width: width)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
        )
    }
}

private struct SuggestionItem: View {
    let title: String
    let height: CGFloat
    let action: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.primary)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .background(isHovering ? Color.blue.opacity(0.1) : Color.clear)
        }
        .buttonStyle(.plain)
        .frame(height: height)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - 预览实战

struct SparkAutocomplete_Previews: PreviewProvider {
    struct AutocompleteLab: View {
        @State private var unitSearch = ""
        @State private var certNumber = ""
        
        let energyUnits = [
            "浙江省电力公司 (Zhejiang Electric Power)",
            "杭州能源集团有限公司",
            "宁波港口能源调度中心",
            "湖州南太湖绿证核验站",
            "衢州碳账户管理中心",
            "嘉兴市分布式光伏监测点"
        ]
        
        let certPrefixes = ["CERT-2026-ZH", "CERT-2026-NB", "CERT-2026-HZ", "CERT-2025-OLD"]

        var body: some View {
            SparkContainer {
                SparkHeader(height: 50) {
                    HStack {
                        Text("业务组件实验室 / Autocomplete")
                            .font(.headline)
                            .padding(.leading)
                        Spacer()
                    }
                    .background(Color.blue.opacity(0.05))
                }

                SparkMain {
                    VStack(alignment: .leading, spacing: 30) {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("报送单位检索", systemImage: "building.2.fill")
                                .font(.subheadline).foregroundColor(.secondary)
                            
                            SparkAutocomplete(
                                text: $unitSearch,
                                placeholder: "请输入单位关键词...",
                                prefixIcon: "magnifyingglass",
                                suggestions: energyUnits
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Label("绿证编号速查", systemImage: "barcode.viewfinder")
                                .font(.subheadline).foregroundColor(.secondary)
                            
                            SparkAutocomplete(
                                text: $certNumber,
                                placeholder: "输入编号...",
                                suggestions: certPrefixes
                            )
                        }
                        Spacer()
                    }
                    .padding(40)
                    .frame(maxWidth: 500)
                }
            }
            .frame(width: 800, height: 500)
        }
    }

    static var previews: some View {
        AutocompleteLab()
    }
}
