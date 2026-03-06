//
//  SparkBadge.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//
import SwiftUI

public struct SparkBadge<Content: View>: View {
    @Environment(\.sparkConfig) private var config
    
    private let content: Content
    private let value: String
    private let max: Int
    private let type: SparkType
    private let isDot: Bool
    private let hidden: Bool
    
    public init(
        value: String = "",
        type: SparkType = .danger,
        max: Int = 99,
        isDot: Bool = false,
        hidden: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.value = value
        self.type = type
        self.max = max
        self.isDot = isDot
        self.hidden = hidden
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            content
            
            // 使用 transition 增加动感，当 hidden 状态改变时会有缩放效果
            if !hidden && shouldShow {
                badgeElement
                    .transition(.scale.combined(with: .opacity))
                    // 核心逻辑：将 Badge 的几何中心对齐到宿主视图的右上角
                    .alignmentGuide(.top) { d in d.height / 2 }
                    .alignmentGuide(.trailing) { d in d.width / 2 }
                    .allowsHitTesting(false) // 角标通常不响应点击，防止遮挡按钮
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: hidden)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: value)
    }

    @ViewBuilder
    private var badgeElement: some View {
        Group {
            if isDot {
                Circle()
                    .fill(badgeColor)
                    .frame(width: 8, height: 8)
                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
            } else {
                Text(displayValue)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .frame(minWidth: 16, minHeight: 16)
                    .background(badgeColor)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white, lineWidth: 1.5))
            }
        }
        // 微弱投影增加立体感
        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
    }

    // 判断逻辑：红点模式直接显示，数字模式需有值才显示
    private var shouldShow: Bool {
        if isDot { return true }
        return !value.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var displayValue: String {
        if let num = Int(value) {
            return num > max ? "\(max)+" : "\(num)"
        }
        return value
    }

    private var badgeColor: Color {
        switch type {
        case .primary: return config.primaryColor
        case .success: return config.successColor
        case .warning: return config.warningColor
        case .danger: return config.dangerColor
        case .default: return Color.gray
        }
    }
}

// --- 完美版综合预览 ---

#Preview {
    struct BadgeDemoContainer: View {
        @State private var count = 8
        @State private var isHidden = false
        
        var body: some View {
            ScrollView {
                VStack(spacing: 40) {
                    
                    // 1. 动态交互展示
                    GroupBox("动态交互 (Interactive)") {
                        VStack(spacing: 20) {
                            HStack(spacing: 40) {
                                SparkBadge(value: "\(count)", type: .danger) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 30))
                                }
                                
                                SparkBadge(type: .success, isDot: true, hidden: isHidden) {
                                    Text("状态点")
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(6)
                                }
                            }
                            
                            HStack {
                                Button("增加数字") { count += 10 }
                                Button(isHidden ? "显示红点" : "隐藏红点") {
                                    withAnimation { isHidden.toggle() }
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.vertical, 10)
                    }

                    // 2. 各种形态对比
                    GroupBox("典型场景 (Scenarios)") {
                        VStack(alignment: .leading, spacing: 25) {
                            // 数字溢出
                            HStack(spacing: 40) {
                                SparkBadge(value: "120", type: .danger, max: 99) {
                                    Text("邮件")
                                }
                                
                                SparkBadge(value: "HOT", type: .warning) {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.orange)
                                }
                                
                                SparkBadge(value: "NEW", type: .primary) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                }
                            }
                            
                            // 头像结合
                            HStack(spacing: 40) {
                                SparkBadge(type: .success, isDot: true) {
                                    SparkAvatar(text: "User", shape: .circle)
                                }
                                
                                SparkBadge(value: "PRO", type: .warning) {
                                    SparkAvatar(url: URL(string: "https://github.com/apple.png"), shape: .rounded)
                                }
                            }
                        }
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            .background(Color.gray.opacity(0.05))
        }
    }
    
    return BadgeDemoContainer()
}
