//
//  SparkStepper.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

public struct SparkStepper: View {
    @Environment(\.sparkConfig) private var config
    @Environment(\.sparkSize) private var envSize
    
    @Binding var value: Int
    private let range: ClosedRange<Int>
    private let step: Int
    private let disabled: Bool
    
    public init(
        _ value: Binding<Int>,
        in range: ClosedRange<Int> = 0...999,
        step: Int = 1,
        disabled: Bool = false
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.disabled = disabled
    }

    public var body: some View {
        HStack(spacing: 0) {
            // 减号按钮
            stepperButton(systemName: "minus", isIncrement: false)
                .disabled(disabled || value <= range.lowerBound)
            
            // 数值显示
            Text("\(value)")
                .font(font)
                .monospacedDigit() // 关键：防止数字变动时宽度跳动
                .frame(minWidth: valueWidth)
                .padding(.horizontal, 8)
                .foregroundColor(disabled ? .secondary : .primary)
            
            // 加号按钮
            stepperButton(systemName: "plus", isIncrement: true)
                .disabled(disabled || value >= range.upperBound)
        }
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(config.cornerRadius)
        .opacity(disabled ? 0.6 : 1.0)
    }

    // MARK: - 子视图：操作按钮
    // 修正：参数改为 Bool，去掉 some
    @ViewBuilder
    private func stepperButton(systemName: String, isIncrement: Bool) -> some View {
        Button {
            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                if isIncrement {
                    if value + step <= range.upperBound { value += step }
                } else {
                    if value - step >= range.lowerBound { value -= step }
                }
            }
        } label: {
            ZStack {
                // 按钮背景：点击时会有默认的淡化效果
                Rectangle()
                    .fill(Color.secondary.opacity(0.1))
                    .frame(width: buttonSize, height: buttonSize)
                
                Image(systemName: systemName)
                    .font(.system(size: iconSize, weight: .bold))
                    .foregroundColor(canPress(isIncrement) ? .primary : .secondary.opacity(0.5))
            }
        }
        .buttonStyle(.plain)
    }

    // 辅助逻辑：判断按钮是否还能点
    private func canPress(_ isIncrement: Bool) -> Bool {
        if disabled { return false }
        return isIncrement ? value < range.upperBound : value > range.lowerBound
    }

    // MARK: - 样式计算
    private var buttonSize: CGFloat {
        switch envSize {
        case .large: return 40
        case .medium: return 32
        case .small: return 28
        case .mini: return 24
        }
    }
    
    private var iconSize: CGFloat {
        switch envSize {
        case .large: return 14
        case .medium: return 12
        case .small: return 10
        case .mini: return 8
        }
    }
    
    private var valueWidth: CGFloat {
        switch envSize {
        case .large: return 40
        case .medium: return 30
        default: return 24
        }
    }
    
    private var font: Font {
        switch envSize {
        case .large: return .body
        case .medium: return .subheadline
        case .small: return .footnote
        case .mini: return .caption
        }
    }
}

#Preview {
    struct StepperDemo: View {
        @State private var val1 = 1
        @State private var val2 = 10
        
        var body: some View {
            VStack(spacing: 30) {
                GroupBox("基础用法") {
                    VStack(spacing: 20) {
                        HStack {
                            Text("购买数量")
                            Spacer()
                            SparkStepper($val1, in: 1...10)
                        }
                    }
                    .padding()
                }
                
                GroupBox("尺寸体系 (Inherit Size)") {
                    VStack(spacing: 20) {
                        SparkStepper($val2).environment(\.sparkSize, .large)
                        SparkStepper($val2).environment(\.sparkSize, .medium)
                        SparkStepper($val2).environment(\.sparkSize, .small)
                        SparkStepper($val2).environment(\.sparkSize, .mini)
                    }
                    .padding()
                }
                
                GroupBox("禁用状态") {
                    SparkStepper(.constant(5), disabled: true)
                        .padding()
                }
            }
            .padding()
        }
    }
    return StepperDemo()
}
