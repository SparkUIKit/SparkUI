//
//  SparkCircleProgress.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

public struct SparkCircleProgress: View {
    @Environment(\.sparkConfig) private var config
    @Environment(\.sparkSize) private var envSize
    
    private let percentage: Double
    private let type: SparkType
    private let showText: Bool
    
    public init(
        _ percentage: Double,
        type: SparkType = .primary,
        showText: Bool = true
    ) {
        self.percentage = max(0, min(100, percentage))
        self.type = type
        self.showText = showText
    }

    public var body: some View {
        ZStack {
            // 底层灰色圆环
            Circle()
                .stroke(Color.secondary.opacity(0.15), lineWidth: strokeWidth)
            
            // 进度圆环
            Circle()
                .trim(from: 0, to: CGFloat(percentage / 100))
                .stroke(
                    statusColor,
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90)) // 从 12 点钟方向开始
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: percentage)
            
            // 中间文字
            if showText {
                VStack(spacing: 0) {
                    Text("\(Int(percentage))")
                        .font(mainFontSize)
                        .fontWeight(.bold)
                    Text("%")
                        .font(unitFontSize)
                }
                .foregroundColor(.primary)
            }
        }
        .frame(width: circleSize, height: circleSize)
    }

    // MARK: - 样式计算 (对齐 SparkTheme)
    
    private var circleSize: CGFloat {
        switch envSize {
        case .large: return 120
        case .medium: return 80
        case .small: return 60
        case .mini: return 40
        }
    }
    
    private var strokeWidth: CGFloat {
        switch envSize {
        case .large: return 12
        case .medium: return 8
        case .small: return 6
        case .mini: return 4
        }
    }
    
    private var mainFontSize: Font {
        switch envSize {
        case .large: return .title
        case .medium: return .headline
        case .small: return .subheadline
        case .mini: return .caption2
        }
    }
    
    private var unitFontSize: Font {
        switch envSize {
        case .large: return .caption
        default: return .system(size: 8)
        }
    }

    private var statusColor: Color {
            switch type {
            case .primary: return config.primaryColor
            case .success: return config.successColor
            case .warning: return config.warningColor
            case .danger: return config.dangerColor
            case .info: return config.infoColor
            case .default: return Color.gray
            @unknown default: return Color.gray
            }
        }
}

#Preview {
    ScrollView {
        VStack(spacing: 40) {
            
            GroupBox("不同状态 (Status Types)") {
                HStack(spacing: 25) {
                    SparkCircleProgress(25, type: .primary)
                    SparkCircleProgress(50, type: .success)
                    SparkCircleProgress(75, type: .warning)
                    SparkCircleProgress(100, type: .danger)
                }
                .padding()
            }
            
            GroupBox("尺寸体系 (Large -> Mini)") {
                HStack(alignment: .bottom, spacing: 20) {
                    SparkCircleProgress(60).environment(\.sparkSize, .large)
                    SparkCircleProgress(60).environment(\.sparkSize, .medium)
                    SparkCircleProgress(60).environment(\.sparkSize, .small)
                    SparkCircleProgress(60).environment(\.sparkSize, .mini)
                }
                .padding()
            }
            
            GroupBox("无文本模式") {
                HStack(spacing: 30) {
                    SparkCircleProgress(40, showText: false)
                        .environment(\.sparkSize, .small)
                    
                    SparkCircleProgress(85, type: .success, showText: false)
                        .environment(\.sparkSize, .small)
                }
                .padding()
            }
        }
        .padding()
    }
}

