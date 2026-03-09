//
//  SparkMessage.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

// --- 1. 数据模型 ---
struct SparkMessageItem: Identifiable {
    let id = UUID()
    let text: String
    let type: SparkType
    var isVisible: Bool = false
}

// --- 2. 全局管理器 ---
@MainActor
public class SparkMessage: ObservableObject {
    public static let shared = SparkMessage()
    @Published var messages: [SparkMessageItem] = []
    
    private init() {}
    
    // 核心静态调用方法
    public static func show(_ text: String, type: SparkType = .success) {
        shared.addMessage(text: text, type: type)
    }
    
    private func addMessage(text: String, type: SparkType) {
        let newMessage = SparkMessageItem(text: text, type: type)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            messages.append(newMessage)
        }
        
        // 3秒后自动移除
        Task {
            try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
            removeMessage(newMessage.id)
        }
    }
    
    private func removeMessage(_ id: UUID) {
        withAnimation(.spring()) {
            messages.removeAll { $0.id == id }
        }
    }
}

// --- 3. UI 视图组件 ---
public struct SparkMessageContainer: View {
    @ObservedObject private var manager = SparkMessage.shared
    @Environment(\.sparkConfig) private var config

    public init() {}

    public var body: some View {
        // 悬浮在屏幕最顶层的容器
        VStack {
            ForEach(manager.messages) { msg in
                HStack(spacing: 12) {
                    Image(systemName: iconName(for: msg.type))
                        .font(.system(size: 14, weight: .bold))
                    
                    Text(msg.text)
                        .font(.system(size: 14))
                }
                .foregroundColor(color(for: msg.type))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(white: 1.0))
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color(for: msg.type).opacity(0.2), lineWidth: 1)
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .scale(scale: 0.8).combined(with: .opacity)
                ))
                .padding(.top, 8)
            }
            Spacer()
        }
        .padding(.top, 50) // 避开刘海屏
        .allowsHitTesting(false) // 确保不遮挡下方按钮点击
    }
    
    // 辅助逻辑
    private func color(for type: SparkType) -> Color {
        switch type {
        case .primary: return config.primaryColor
        case .success: return config.successColor
        case .warning: return config.warningColor
        case .danger: return config.dangerColor
        case .info: return config.infoColor
        case .default: return .gray
        }
    }
    
    private func iconName(for type: SparkType) -> String {
        switch type {
        case .primary: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .danger: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        case .default: return "bell.fill"
        }
    }
}

#Preview {
    ZStack {
        VStack(spacing: 20) {
            Text("SparkMessage 测试").font(.headline)
            
            Button("成功消息") {
                SparkMessage.show("恭喜，操作成功！", type: .success)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            
            Button("警告消息") {
                SparkMessage.show("警告：检测到异常登录", type: .warning)
            }
            .buttonStyle(.bordered)
            .tint(.orange)
            
            Button("错误消息") {
                SparkMessage.show("保存失败，请检查网络连接", type: .danger)
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        
        // 预览也需要挂载容器
        SparkMessageContainer()
    }
    .frame(width: 393, height: 452)
    .background(Color.gray.opacity(0.05))
}
