//
//  SparkProgress.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

public struct SparkProgress: View {
    @Environment(\.sparkConfig) private var config
    @Environment(\.sparkSize) private var envSize
    
    private let percentage: Double // 0.0 到 100.0
    private let type: SparkType
    private let showText: Bool
    private let striped: Bool // 是否开启条纹动效
    
    public init(
        _ percentage: Double,
        type: SparkType = .primary,
        showText: Bool = false,
        striped: Bool = false
    ) {
        // 限制百分比在 0-100 之间
        self.percentage = max(0, min(100, percentage))
        self.type = type
        self.showText = showText
        self.striped = striped
    }

    public var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 轨道背景
                    Capsule()
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: barHeight)
                    
                    // 进度条填充
                    Capsule()
                        .fill(statusColor)
                        .frame(width: CGFloat(percentage / 100) * geometry.size.width, height: barHeight)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: percentage)
                    
                    // 条纹动效层 (如果是 striped 模式)
                    if striped && percentage > 0 {
                        stripedOverlay
                            .mask(
                                Capsule()
                                    .frame(width: CGFloat(percentage / 100) * geometry.size.width, height: barHeight)
                            )
                    }
                }
            }
            .frame(height: barHeight)
            
            if showText {
                Text("\(Int(percentage))%")
                    .font(font)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - 子视图：条纹动效
    private var stripedOverlay: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            let offset = CGFloat((t * 20).truncatingRemainder(dividingBy: 40))
            
            HStack(spacing: 0) {
                ForEach(0..<20) { _ in
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 20)
                        .skew() // 自定义斜切
                }
            }
            .offset(x: offset - 40)
        }
    }

    // MARK: - 样式计算
    private var barHeight: CGFloat {
        switch envSize {
        case .large: return 12
        case .medium: return 8
        case .small: return 6
        case .mini: return 4
        }
    }
    
    private var font: Font {
        switch envSize {
        case .large: return .footnote
        default: return .caption2
        }
    }

    private var statusColor: Color {
        switch type {
        case .primary: return config.primaryColor
        case .success: return config.successColor
        case .warning: return config.warningColor
        case .danger: return config.dangerColor
        case .default: return .gray
        }
    }
}

// 辅助：斜切效果
extension View {
    func skew() -> some View {
        self.modifier(SkewModifier())
    }
}

struct SkewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.transformEffect(.init(a: 1, b: 0, c: -0.5, d: 1, tx: 0, ty: 0))
    }
}

#Preview {
    VStack(spacing: 40) {
        
        GroupBox("基础用法 & 状态展示") {
            VStack(spacing: 20) {
                SparkProgress(30, type: .primary)
                SparkProgress(60, type: .success, showText: true)
                SparkProgress(80, type: .warning)
                SparkProgress(100, type: .danger)
            }
            .padding()
        }
        
        GroupBox("尺寸体系 (Inherit Size)") {
            VStack(spacing: 20) {
                SparkProgress(50).environment(\.sparkSize, .large)
                SparkProgress(50).environment(\.sparkSize, .medium)
                SparkProgress(50).environment(\.sparkSize, .small)
                SparkProgress(50).environment(\.sparkSize, .mini)
            }
            .padding()
        }
        
        GroupBox("动态条纹动效") {
            SparkProgress(75, type: .primary, striped: true)
                .padding()
        }
    }
    .padding()
}
