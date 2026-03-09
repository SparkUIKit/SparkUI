//
//  SparkTheme.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

// MARK: - 基础配置

/// SparkUI 的全局基础配置，包含颜色、圆角及间距体系
public struct SparkConfig: Sendable {
    
    // MARK: 语义颜色
    /// 品牌主色调，默认为蓝色
    public var primaryColor: Color = .blue
    /// 成功状态色，通常用于表达运行正常、验证通过
    public var successColor: Color = .green
    /// 警告状态色，用于提醒潜在风险
    public var warningColor: Color = .orange
    /// 危险状态色，用于表达报错、故障或离线
    public var dangerColor: Color = .red
    /// 信息提示色，用于中性的辅助信息说明
    public var infoColor: Color = Color(white: 0.6)
    
    // MARK: 基础样式
    /// 组件库的基础圆角数值，默认为 8
    public var cornerRadius: CGFloat = 8
    
    // MARK: 间距体系
    /// 极小间距 (4pt)，适用于紧凑排版
    public var spacingMini: CGFloat = 4
    /// 小间距 (8pt)，适用于元素内部间距
    public var spacingSmall: CGFloat = 8
    /// 中等间距 (16pt)，标准页面元素间距
    public var spacingMedium: CGFloat = 16
    /// 大间距 (24pt)，适用于区块间的隔离
    public var spacingLarge: CGFloat = 24
    
    public init() {}
    
    /// 根据传入的语义类型获取配置中对应的颜色值
    /// - Parameter type: 语义化类型 (SparkType)
    /// - Returns: 对应的 SwiftUI Color 对象
    public func color(for type: SparkType) -> Color {
        switch type {
        case .primary: return primaryColor
        case .success: return successColor
        case .warning: return warningColor
        case .danger: return dangerColor
        case .info:    return infoColor
        case .default: return Color.gray
        @unknown default: return primaryColor
        }
    }
}

// MARK: - 枚举定义

/// 全局通用的语义化类型，定义了组件的视觉基调
public enum SparkType: String, Sendable, CaseIterable {
    /// 默认/中性状态
    case `default`
    /// 主题/高亮状态
    case primary
    /// 成功/正常状态
    case success
    /// 警告/提醒状态
    case warning
    /// 错误/危险状态
    case danger
    /// 信息/辅助状态
    case info
}

/// SparkUI 的尺寸体系，支持从极小到大的四档调节
public enum SparkSize: String, Sendable, CaseIterable {
    /// 大尺寸
    case large
    /// 中等尺寸 (默认)
    case medium
    /// 小尺寸
    case small
    /// 极小尺寸
    case mini
    
    /// 获取当前尺寸在指定配置中对应的具体 CGFloat 数值
    /// - Parameter config: 全局配置对象
    /// - Returns: 对应的间距或尺寸数值
    public func value(in config: SparkConfig) -> CGFloat {
        switch self {
        case .large: return config.spacingLarge
        case .medium: return config.spacingMedium
        case .small: return config.spacingSmall
        case .mini: return config.spacingMini
        }
    }
}

/// 组件的主题外观模式
public enum SparkEffect: String, Sendable, CaseIterable {
    /// 深色模式：实心背景，通常配白色文字
    case dark
    /// 浅色模式：浅色背景，通常配有色文字
    case light
    /// 朴素模式：透明/白色背景，有色边框
    case plain
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

// MARK: - View 扩展

extension View {
    /// 统一设置当前视图及其子视图中 SparkUI 组件的尺寸
    /// - Parameter size: 目标尺寸
    public func sparkSize(_ size: SparkSize) -> some View {
        environment(\.sparkSize, size)
    }
    
    /// 注入自定义的 SparkUI 全局配置对象
    /// - Parameter config: 配置对象
    public func sparkConfig(_ config: SparkConfig) -> some View {
        environment(\.sparkConfig, config)
    }
}
