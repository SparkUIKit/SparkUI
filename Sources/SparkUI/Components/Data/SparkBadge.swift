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
    private let type: SparkType
    private let max: Int
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
            
            if !hidden && shouldShow {
                badgeElement
                    .transition(.scale.combined(with: .opacity))
                    .alignmentGuide(.top) { d in d.height / 2 }
                    .alignmentGuide(.trailing) { d in d.width / 2 }
                    .allowsHitTesting(false)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: hidden)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: value)
    }

    @ViewBuilder
    private var badgeElement: some View {
        if isDot {
            Circle()
                .fill(config.color(for: type))
                .frame(width: 8, height: 8)
                .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
        } else {
            Text(displayValue)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 5)
                .frame(minWidth: 16, minHeight: 16)
                .background(config.color(for: type))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white, lineWidth: 1.5))
        }
    }

    private var shouldShow: Bool {
        isDot || !value.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var displayValue: String {
        if let num = Int(value) {
            return num > max ? "\(max)+" : "\(num)"
        }
        return value
    }
}


#Preview("SparkBadge 演示") {
    BadgePreview()
}

struct BadgePreview: View {
    @State private var count = 95
    @State private var isHidden = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // 测试 1: 基础展示
                GroupBox("基础展示") {
                    HStack(spacing: 40) {
                        // 严格匹配 init 顺序
                        SparkBadge(value: "\(count)", type: .danger, max: 99) {
                            Image(systemName: "bell.fill").font(.title)
                        }
                        
                        SparkBadge(value: "New", type: .primary) {
                            Text("消息").padding(10).background(Color.gray.opacity(0.1)).cornerRadius(8)
                        }
                        
                        SparkBadge(type: .success, isDot: true) {
                            Circle().fill(Color.gray.opacity(0.2)).frame(width: 40, height: 40)
                        }
                    }
                    .padding()
                }
                
                // 测试 2: 交互
                GroupBox("交互测试") {
                    VStack(spacing: 20) {
                        HStack {
                            Button("增加") { count += 5 }
                            Button("隐藏/显示红点") { isHidden.toggle() }
                        }
                        .buttonStyle(.bordered)
                        
                        SparkBadge(type: .warning, isDot: true, hidden: isHidden) {
                            Text("状态监控").font(.headline)
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
        .background(Color(white: 0.95))
    }
}
