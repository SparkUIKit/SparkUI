//
//  SparkRollingNumber.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/9.
//

import SwiftUI

public struct SparkRollingNumber: View, Animatable {
    
    public var value: Double
    public var precision: Int
    
    nonisolated public var animatableData: Double {
        get { value }
        set { value = newValue }
    }
    
    public init(value: Double, precision: Int = 1) {
        self.value = value
        self.precision = precision
    }
    
    public var body: some View {
        Text(String(format: "%.\(precision)f", value))
            // 提示：使用 monospacedDigit 确保数字变化时宽度固定，防止文字抖动
            .font(.system(.title3, design: .rounded).monospacedDigit())
            .modifier(RollingAnimationModifier(value: value))
    }
}

/// 方案 2：提取 Modifier 处理版本差异
/// 解决 'numericText(value:)' is only available in macOS 14.0 or newer 的报错
struct RollingAnimationModifier: ViewModifier {
    var value: Double
    
    func body(content: Content) -> some View {
        if #available(macOS 14.0, iOS 17.0, *) {
            content.contentTransition(.numericText(value: value))
        } else {
            // 在 macOS 12/13 上，由于有 Animatable 协议，
            // 数字仍会平滑变化，只是没有系统级的“滚动”视觉过渡
            content
        }
    }
}
