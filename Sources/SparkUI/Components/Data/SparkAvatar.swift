//
//  SparkAvatar.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

// --- 辅助：类型擦除包装器，解决 Shape 类型不一致报错 ---
public struct AnyShape: Shape {
    private let path: @Sendable (CGRect) -> Path

    public init<S: Shape>(_ shape: S) {
        path = { rect in shape.path(in: rect) }
    }

    public func path(in rect: CGRect) -> Path {
        path(rect)
    }
}

public struct SparkAvatar: View {
    @Environment(\.sparkConfig) private var config
    @Environment(\.sparkSize) private var envSize
    
    public enum ShapeMode: Sendable {
        case circle, square, rounded
    }
    
    let url: URL?
    let icon: String?
    let text: String?
    let shapeMode: ShapeMode
    
    public init(
        url: URL? = nil,
        icon: String? = nil,
        text: String? = nil,
        shape: ShapeMode = .circle
    ) {
        self.url = url
        self.icon = icon
        self.text = text
        self.shapeMode = shape
    }
    
    public var body: some View {
        Group {
            if let url = url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholderView
                    case .empty:
                        ProgressView().scaleEffect(0.8)
                    @unknown default:
                        placeholderView
                    }
                }
            } else if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: avatarSize * 0.5))
                    .foregroundColor(.white)
            } else if let text = text {
                Text(text.prefix(1))
                    .font(.system(size: avatarSize * 0.45, weight: .bold))
                    .foregroundColor(.white)
            } else {
                placeholderView
            }
        }
        .frame(width: avatarSize, height: avatarSize)
        .background(Color.gray.opacity(0.3))
        .clipShape(currentShape) // 使用处理后的 Shape
        .overlay(
            currentShape.stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
        )
    }
    
    @ViewBuilder
    private var placeholderView: some View {
        ZStack {
            Color.gray.opacity(0.2)
            Image(systemName: "person.fill")
                .foregroundColor(.white)
        }
    }
    
    // 修正后的形状计算逻辑
    private var currentShape: AnyShape {
        switch shapeMode {
        case .circle:
            return AnyShape(Circle())
        case .square:
            return AnyShape(Rectangle())
        case .rounded:
            return AnyShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private var avatarSize: CGFloat {
        switch envSize {
        case .large: return 56
        case .medium: return 40
        case .small: return 32
        case .mini: return 24
        }
    }
}

// --- 预览代码：修正了调用参数顺序问题 ---

#Preview {
    VStack(spacing: 30) {
        // 1. 不同形态
        HStack(spacing: 20) {
            SparkAvatar(url: URL(string: "https://avatars.githubusercontent.com/u/1?v=4"))
            SparkAvatar(url: URL(string: "https://avatars.githubusercontent.com/u/1?v=4"), shape: .rounded)
            SparkAvatar(url: URL(string: "https://avatars.githubusercontent.com/u/1?v=4"), shape: .square)
        }
        
        // 2. 不同尺寸 (继承环境)
        HStack(alignment: .bottom, spacing: 20) {
            SparkAvatar(url: URL(string: "https://avatars.githubusercontent.com/u/1?v=4")).environment(\.sparkSize, .large)
            SparkAvatar(url: URL(string: "https://avatars.githubusercontent.com/u/1?v=4")).environment(\.sparkSize, .medium)
            SparkAvatar(url: URL(string: "https://avatars.githubusercontent.com/u/1?v=4")).environment(\.sparkSize, .small)
            SparkAvatar(url: URL(string: "https://avatars.githubusercontent.com/u/1?v=4")).environment(\.sparkSize, .mini)
        }
        
        SparkCard(title: "用户信息") {
            HStack(spacing: 12) {
                SparkBadge(type: .success, isDot: true) {
                    SparkAvatar(url: URL(string: "https://github.com/apple.png"))
                }
                
                VStack(alignment: .leading) {
                    Text("Apple Service").font(.headline)
                    Text("在线").font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                
                Button("关注") {}
                    .font(.caption.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
        }
    }
    .padding()
}
