//
//  SparkActionSheet.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

// MARK: - 模型定义
public struct SparkActionItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let subtitle: String?
    public let icon: String?
    public let isDestructive: Bool
    public let action: () -> Void
    
    public init(title: String, subtitle: String? = nil, icon: String? = nil, isDestructive: Bool = false, action: @escaping () -> Void = {}) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isDestructive = isDestructive
        self.action = action
    }
}

// MARK: - 组件主体
public struct SparkActionSheet: View {
    @Environment(\.sparkConfig) private var config
    @Binding var isPresented: Bool
    
    let title: String?
    let items: [SparkActionItem]
    let cancelTitle: String
    
    public var body: some View {
        VStack(spacing: 8) {
            Spacer()
            
            VStack(spacing: 0) {
                if let title = title {
                    Text(title)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding()
                    Divider()
                }
                
                ForEach(items) { item in
                    actionButton(for: item)
                    if item.id != items.last?.id {
                        Divider()
                    }
                }
            }
            .background(adaptiveContentBackground)
            .cornerRadius(config.cornerRadius)
            
            Button {
                isPresented = false
            } label: {
                Text(cancelTitle)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(adaptiveContentBackground)
                    .cornerRadius(config.cornerRadius)
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func actionButton(for item: SparkActionItem) -> some View {
        Button {
            isPresented = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                item.action()
            }
        } label: {
            HStack {
                if let icon = item.icon {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .frame(width: 24)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.body)
                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
            .padding()
            .foregroundColor(item.isDestructive ? .red : .primary)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var adaptiveContentBackground: Color {
        #if os(iOS)
        return Color(uiColor: .secondarySystemGroupedBackground)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }
}

// MARK: - 关键扩展 (修复 no member 'sparkActionSheet')
public extension View {
    func sparkActionSheet(
        isPresented: Binding<Bool>,
        title: String? = nil,
        items: [SparkActionItem],
        cancelTitle: String = "取消"
    ) -> some View {
        ZStack {
            self
            
            if isPresented.wrappedValue {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { isPresented.wrappedValue = false }
                    .transition(.opacity)
                
                SparkActionSheet(
                    isPresented: isPresented,
                    title: title,
                    items: items,
                    cancelTitle: cancelTitle
                )
                .zIndex(1)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isPresented.wrappedValue)
    }
}

// MARK: - 预览
#Preview {
    ActionSheetDemo()
}

struct ActionSheetDemo: View {
    @State private var showSheet = false
    
    var body: some View {
        VStack {
            Button("显示操作面板") {
                showSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor) // 修复颜色报错
        .sparkActionSheet(
            isPresented: $showSheet,
            title: "确定要修改此项目吗？",
            items: [
                SparkActionItem(title: "编辑内容", subtitle: "修改文字、图片和排版", icon: "pencil"),
                SparkActionItem(title: "分享链接", icon: "square.and.arrow.up"),
                SparkActionItem(title: "删除项目", icon: "trash", isDestructive: true)
            ]
        )
    }

    private var backgroundColor: Color {
        #if os(iOS)
        return Color(uiColor: .systemGroupedBackground)
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
}
