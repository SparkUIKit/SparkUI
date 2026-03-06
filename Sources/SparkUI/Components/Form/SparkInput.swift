//
//  SparkInput.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

public struct SparkInput: View {
    @Environment(\.sparkConfig) private var config
    @Environment(\.sparkSize) private var envSize
    
    @Binding var text: String
    public var placeholder: String
    public var isPassword: Bool
    public var disabled: Bool
    public var prefixIcon: String?  // 前置图标
    public var suffixIcon: String?  // 后置图标
    
    @FocusState private var isFocused: Bool
    @State private var isPasswordVisible: Bool = false // 密码明文切换状态
    
    public init(
        text: Binding<String>,
        placeholder: String = "请输入内容",
        isPassword: Bool = false,
        disabled: Bool = false,
        prefixIcon: String? = nil,
        suffixIcon: String? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.isPassword = isPassword
        self.disabled = disabled
        self.prefixIcon = prefixIcon
        self.suffixIcon = suffixIcon
    }

    public var body: some View {
        HStack(spacing: 8) {
            // --- 前置图标 ---
            if let icon = prefixIcon {
                Image(systemName: icon)
                    .foregroundColor(.secondary.opacity(0.8))
                    .font(iconFontSize)
            }
            
            // --- 输入核心区域 ---
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.secondary.opacity(0.5))
                        .font(fontSize)
                }
                
                Group {
                    if isPassword && !isPasswordVisible {
                        SecureField("", text: $text)
                    } else {
                        TextField("", text: $text)
                    }
                }
                .focused($isFocused)
                .font(fontSize)
                .disabled(disabled)
                #if os(macOS)
                .textFieldStyle(.plain)
                #endif
            }
            
            // --- 后置功能区 ---
            HStack(spacing: 6) {
                // 清除按钮：仅在有内容、非禁用时显示
                if !text.isEmpty && !disabled {
                    Button { text = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }

                // 密码切换按钮
                if isPassword && !text.isEmpty && !disabled {
                    Button { isPasswordVisible.toggle() } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
                
                // 后置自定义图标
                if let sIcon = suffixIcon {
                    Image(systemName: sIcon)
                        .foregroundColor(.secondary)
                        .font(iconFontSize)
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
        .frame(height: inputHeight)
        // 背景层
        .background(
            RoundedRectangle(cornerRadius: config.cornerRadius)
                .fill(disabled ? Color.secondary.opacity(0.05) : getSystemBgColor())
        )
        // 边框层
        .overlay(
            RoundedRectangle(cornerRadius: config.cornerRadius)
                .stroke(strokeColor, lineWidth: isFocused ? 1.5 : 1)
        )
        .animation(.easeOut(duration: 0.2), value: isFocused)
        .contentShape(Rectangle())
        .onTapGesture { if !disabled { isFocused = true } }
    }
    
    // --- 动态计算逻辑 (对齐 SparkTheme) ---
    
    private var strokeColor: Color {
        if disabled { return Color.secondary.opacity(0.1) }
        return isFocused ? config.primaryColor : Color.secondary.opacity(0.2)
    }

    private var fontSize: Font {
        switch envSize {
        case .large:  return .body
        case .medium: return .subheadline
        case .small:  return .footnote
        case .mini:   return .caption2
        }
    }
    
    private var iconFontSize: Font {
        switch envSize {
        case .large:  return .system(size: 16)
        case .mini:   return .system(size: 10)
        default:      return .system(size: 14)
        }
    }

    private var inputHeight: CGFloat {
        switch envSize {
        case .large:  return 42
        case .medium: return 36
        case .small:  return 30
        case .mini:   return 24
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch envSize {
        case .large: return 12
        case .mini:  return 6
        default:     return 10
        }
    }

    private func getSystemBgColor() -> Color {
        #if os(iOS)
        return Color(UIColor.systemBackground)
        #elseif os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #else
        return .white
        #endif
    }
}

#Preview {
    struct InputLabContainer: View {
        @State private var username = ""
        @State private var password = ""
        @State private var search = "Gemini"
        
        var body: some View {
            VStack(spacing: 20) {
                SparkInput(text: $username, placeholder: "用户名", prefixIcon: "person")
                    .environment(\.sparkSize, .large)
                
                SparkInput(text: $password, placeholder: "密码", isPassword: true, prefixIcon: "lock")
                    .environment(\.sparkSize, .medium)
                
                SparkInput(text: $search, prefixIcon: "magnifyingglass")
                    .environment(\.sparkSize, .small)
                
                SparkInput(text: .constant("禁用状态"), disabled: true)
                    .environment(\.sparkSize, .medium)
            }
            .padding()
            .frame(width: 350)
        }
    }
    return InputLabContainer()
}
