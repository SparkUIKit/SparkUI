//
//  SparkSlider.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

public struct SparkSlider: View {
    @Environment(\.sparkConfig) private var config
    @Environment(\.sparkSize) private var envSize
    
    @Binding var value: Double
    private let range: ClosedRange<Double>
    private let disabled: Bool
    
    public init(
        _ value: Binding<Double>,
        in range: ClosedRange<Double> = 0...100,
        disabled: Bool = false
    ) {
        self._value = value
        self.range = range
        self.disabled = disabled
    }

    public var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let radius = knobSize / 2
            // 计算当前滑块的偏移量
            let currentOffset = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * width

            ZStack(alignment: .leading) {
                // 1. 底层轨道 (Background Track)
                Capsule()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: trackHeight)
                
                // 2. 激活进度条 (Active Track)
                Capsule()
                    .fill(disabled ? Color.gray.opacity(0.4) : config.primaryColor)
                    .frame(width: max(0, currentOffset), height: trackHeight)
                
                // 3. 滑块圆点 (Knob)
                Circle()
                    .fill(Color.white)
                    .frame(width: knobSize, height: knobSize)
                    .shadow(radius: isDragging ? 3 : 1, y: 1)
                    .overlay(
                        Circle()
                            .stroke(config.primaryColor.opacity(0.2), lineWidth: 0.5)
                    )
                    .offset(x: currentOffset - radius)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                if !disabled {
                                    updateValue(with: gesture.location.x, in: width)
                                }
                            }
                    )
            }
            .frame(maxHeight: .infinity)
        }
        .frame(height: max(knobSize, 30))
        .opacity(disabled ? 0.6 : 1.0)
    }

    
    @State private var isDragging = false

    private func updateValue(with x: CGFloat, in totalWidth: CGFloat) {
        let percent = Double(max(0, min(x, totalWidth)) / totalWidth)
        let newValue = range.lowerBound + percent * (range.upperBound - range.lowerBound)
        self.value = newValue
    }

    
    private var trackHeight: CGFloat {
        switch envSize {
        case .large: return 6
        case .medium: return 4
        case .small: return 3
        case .mini: return 2
        }
    }
    
    private var knobSize: CGFloat {
        switch envSize {
        case .large: return 20
        case .medium: return 16
        case .small: return 12
        case .mini: return 10
        }
    }
}

#Preview {
    struct SliderDemo: View {
        @State private var val1: Double = 30
        @State private var val2: Double = 50
        @State private var val3: Double = 80
        
        var body: some View {
            VStack(spacing: 40) {
                
                GroupBox("基础用法 (\(Int(val1))%)") {
                    SparkSlider($val1)
                        .padding(.vertical, 10)
                }
                
                GroupBox("尺寸对比 (Large / Medium / Small)") {
                    VStack(spacing: 25) {
                        SparkSlider($val2).environment(\.sparkSize, .large)
                        SparkSlider($val2).environment(\.sparkSize, .medium)
                        SparkSlider($val2).environment(\.sparkSize, .small)
                        SparkSlider($val2).environment(\.sparkSize, .mini)
                    }
                    .padding(.vertical, 10)
                }
                
                GroupBox("禁用状态") {
                    SparkSlider($val3, disabled: true)
                        .padding(.vertical, 10)
                }
            }
            .padding()
            .frame(maxWidth: 400)
        }
    }
    return SliderDemo()
}
