//
//  SparkTheme.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

// MARK: - 基础配置
public struct SparkConfig: Sendable {
    public var primaryColor: Color = .blue
    public var successColor: Color = .green
    public var warningColor: Color = .orange
    public var dangerColor: Color = .red
    public var cornerRadius: CGFloat = 8
    
    public init() {}
}

// MARK: - 枚举定义

/// 全局通用的语义化类型 (对标 Element Plus 的 Type)
public enum SparkType: Sendable {
    case `default`
    case primary
    case success
    case warning
    case danger
}

/// 尺寸体系
public enum SparkSize: Sendable {
    case large
    case medium
    case small
    case mini
}

/// 主题模式
public enum SparkEffect: Sendable {
    case dark    // 实心模式
    case light   // 浅色背景 (默认)
    case plain   // 白底边框模式
}

// MARK: - 环境键定义

private struct SparkConfigKey: EnvironmentKey {
    static let defaultValue = SparkConfig()
}

private struct SparkSizeKey: EnvironmentKey {
    static let defaultValue: SparkSize = .medium
}

// MARK: - 环境值扩展

extension EnvironmentValues {
    /// 访问全局主题配置
    public var sparkConfig: SparkConfig {
        get { self[SparkConfigKey.self] }
        set { self[SparkConfigKey.self] = newValue }
    }
    
    /// 访问当前层级的组件尺寸
    public var sparkSize: SparkSize {
        get { self[SparkSizeKey.self] }
        set { self[SparkSizeKey.self] = newValue }
    }
}
