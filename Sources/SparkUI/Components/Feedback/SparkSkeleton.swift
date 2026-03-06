//
//  SparkSkeleton.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

//
//  SparkSkeleton.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

public struct SparkSkeleton: View {
    @Environment(\.sparkConfig) private var config
    
    public enum ShapeType {
        case circle, rect, capsule
    }
    
    private let shape: ShapeType
    private let width: CGFloat?
    private let height: CGFloat?
    
    public init(shape: ShapeType = .rect, width: CGFloat? = nil, height: CGFloat? = nil) {
        self.shape = shape
        self.width = width
        self.height = height
    }

    public var body: some View {
        // 在内部完成填充，因为 fill 属于 Shape 协议
        Group {
            switch shape {
            case .circle:
                Circle().fill(skeletonColor)
            case .capsule:
                Capsule().fill(skeletonColor)
            case .rect:
                RoundedRectangle(cornerRadius: config.cornerRadius).fill(skeletonColor)
            }
        }
        .frame(width: width, height: height)
        .shimmer() // 应用流光动画
    }
    
    private var skeletonColor: Color {
        Color.secondary.opacity(0.15)
    }
}

// MARK: - 流光动画修饰符 (保持不变)
public struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1.5

    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .white.opacity(0.5), location: 0.5),
                            .init(color: .clear, location: 1)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .scaleEffect(x: 2)
                    .offset(x: phase * geometry.size.width)
                    .onAppear {
                        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                            phase = 1.5
                        }
                    }
                }
            )
            .clipped()
    }
}

public extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

// MARK: - 预览
#Preview {
    ScrollView {
        VStack(spacing: 30) {
            
            GroupBox("基础组件") {
                HStack(spacing: 20) {
                    SparkSkeleton(shape: .circle, width: 50, height: 50)
                    VStack(alignment: .leading, spacing: 10) {
                        SparkSkeleton(width: 150, height: 15)
                        SparkSkeleton(width: 100, height: 15)
                    }
                }
                .padding()
            }
            
            GroupBox("实际列表应用示例") {
                VStack(spacing: 15) {
                    ForEach(0..<3, id: \.self) { _ in
                        HStack(spacing: 12) {
                            SparkSkeleton(shape: .rect, width: 60, height: 60)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                SparkSkeleton(shape: .capsule, width: 200, height: 12)
                                SparkSkeleton(shape: .capsule, width: 140, height: 12)
                                SparkSkeleton(shape: .capsule, width: 80, height: 12)
                            }
                        }
                    }
                }
                .padding()
            }
            
            GroupBox("对现有组件进行骨架化") {
                // 模拟一个按钮加载时的状态
                VStack(spacing: 20) {
                    Text("确认提交")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .shimmer() // 核心功能：直接为普通视图添加流光
                    
                    Text("加载中...")
                        .font(.caption)
                        .shimmer()
                }
                .padding()
            }
        }
        .padding()
    }
}
