//
//  SparkTheme.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

// MARK: - 基础配置
public struct SparkConfig: Sendable {
    // 语义颜色
    public var primaryColor: Color = .blue
    public var successColor: Color = .green
    public var warningColor: Color = .orange
    public var dangerColor: Color = .red
    public var infoColor: Color = Color(white: 0.6)
    
    // 基础圆角
    public var cornerRadius: CGFloat = 8
    
    // 间距体系 (用于 SparkSpace)
    public var spacingMini: CGFloat = 4
    public var spacingSmall: CGFloat = 8
    public var spacingMedium: CGFloat = 16
    public var spacingLarge: CGFloat = 24
    
    public init() {}
    
    /// 根据类型获取对应的颜色
    public func color(for type: SparkType) -> Color {
        switch type {
        case .primary: return primaryColor
        case .success: return successColor
        case .warning: return warningColor
        case .danger: return dangerColor
        case .info, .default: return infoColor
        }
    }
}

// MARK: - 枚举定义

/// 全局通用的语义化类型
public enum SparkType: String, Sendable, CaseIterable {
    case `default`
    case primary
    case success
    case warning
    case danger
    case info
}

/// 尺寸体系
public enum SparkSize: String, Sendable, CaseIterable {
    case large
    case medium
    case small
    case mini
    
    /// 获取对应的间距数值
    public func value(in config: SparkConfig) -> CGFloat {
        switch self {
        case .large: return config.spacingLarge
        case .medium: return config.spacingMedium
        case .small: return config.spacingSmall
        case .mini: return config.spacingMini
        }
    }
}

/// 主题外观模式
public enum SparkEffect: String, Sendable, CaseIterable {
    case dark    // 实心背景，白色文字
    case light   // 浅色背景，有色文字
    case plain   // 白色背景，有色边框
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
    /// 访问或修改全局主题配置
    public var sparkConfig: SparkConfig {
        get { self[SparkConfigKey.self] }
        set { self[SparkConfigKey.self] = newValue }
    }
    
    /// 访问或修改当前视图层级的组件尺寸
    public var sparkSize: SparkSize {
        get { self[SparkSizeKey.self] }
        set { self[SparkSizeKey.self] = newValue }
    }
}

// MARK: - View 扩展 (方便链式调用)
extension View {
    /// 统一设置 SparkUI 的尺寸
    public func sparkSize(_ size: SparkSize) -> some View {
        environment(\.sparkSize, size)
    }
    
    /// 统一设置 SparkUI 的全局配置
    public func sparkConfig(_ config: SparkConfig) -> some View {
        environment(\.sparkConfig, config)
    }
}
