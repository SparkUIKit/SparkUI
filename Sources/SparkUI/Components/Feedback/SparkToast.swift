//
//  SparkToast.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

// MARK: - 状态模型
public enum SparkToastStyle {
    case success, error, loading, info
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .loading: return "ellipsis.circle.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .loading: return .blue
        case .info: return .gray
        }
    }
}

// MARK: - 主体视图
public struct SparkToast: View {
    @Environment(\.sparkConfig) private var config
    let style: SparkToastStyle
    let message: String
    
    public var body: some View {
        HStack(spacing: 12) {
            if style == .loading {
                ProgressView()
                    .controlSize(.small)
            } else {
                Image(systemName: style.icon)
                    .foregroundColor(style.color)
            }
            
            Text(message)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: config.cornerRadius)
                // 修正点 1：显式使用 uiColor 标签，并适配平台
                .fill(adaptiveBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var adaptiveBackground: Color {
        #if os(iOS)
        return Color(uiColor: .systemBackground)
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
}

// MARK: - 逻辑控制器
public extension View {
    func sparkToast(
        isPresented: Binding<Bool>,
        style: SparkToastStyle = .info,
        message: String,
        duration: Double = 2.0
    ) -> some View {
        ZStack(alignment: .top) {
            self
            
            if isPresented.wrappedValue {
                SparkToast(style: style, message: message)
                    .padding(.top, 20)
                    .zIndex(999)
                    .onAppear {
                        if style != .loading {
                            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                withAnimation(.spring()) {
                                    isPresented.wrappedValue = false
                                }
                            }
                        }
                    }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented.wrappedValue)
    }
}

// MARK: - 预览
#Preview {
    ToastDemo()
}

struct ToastDemo: View {
    @State private var showSuccess = false
    @State private var showError = false
    @State private var showLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button("成功提示") { showSuccess = true }
                .buttonStyle(.bordered)
            
            Button("错误警告") { showError = true }
                .buttonStyle(.bordered)
                .tint(.red)
            
            Button("加载中 (不自动消失)") {
                showLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showLoading = false
                }
            }
            .buttonStyle(.bordered)
            .tint(.blue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // 修正点 2：显式使用平台适配背景色
        .background(adaptiveGroupedBackground)
        .sparkToast(isPresented: $showSuccess, style: .success, message: "保存成功")
        .sparkToast(isPresented: $showError, style: .error, message: "网络连接失败")
        .sparkToast(isPresented: $showLoading, style: .loading, message: "正在处理...")
    }
    
    private var adaptiveGroupedBackground: Color {
        #if os(iOS)
        return Color(uiColor: .systemGroupedBackground)
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
}
