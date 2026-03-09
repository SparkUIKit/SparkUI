//
//  SparkStatCard.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/9.
//

import SwiftUI

public struct SparkStatCard: View {
    @Environment(\.sparkConfig) private var config
    
    let title: String
    let value: Double      // 确保是 Double
    let unit: String
    let trend: Double?
    let type: SparkType
    let precision: Int
    
    public init(
        title: String,
        value: Double,
        unit: String,
        trend: Double? = nil,
        type: SparkType = .primary,
        precision: Int = 1
    ) {
        self.title = title
        self.value = value
        self.unit = unit
        self.trend = trend
        self.type = type
        self.precision = precision
    }
    
    public var body: some View {
        SparkCard {
            VStack(alignment: .leading, spacing: config.spacingSmall) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    // 调用组件
                    SparkRollingNumber(value: value, precision: precision)
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(config.color(for: type))
                    
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let trend = trend {
                    trendView(trend)
                }
            }
            .padding(config.spacingMedium)
        }
        // 关键：值变化时触发动画
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: value)
    }
    
    @ViewBuilder
    private func trendView(_ value: Double) -> some View {
        HStack(spacing: 4) {
            Image(systemName: value >= 0 ? "arrow.up.right" : "arrow.down.right")
            Text(String(format: "%.1f%%", abs(value * 100)))
            Text(value >= 0 ? "同比上升" : "同比下降")
        }
        .font(.caption)
        .foregroundColor(value >= 0 ? config.dangerColor : config.successColor)
    }
}

#Preview {
    VStack(spacing: 20) {
        // 确保这里的 value 传入的是 Double
        SparkStatCard(title: "当日总耗电", value: 1284.5, unit: "kWh", trend: 0.12, type: .primary)
        SparkStatCard(title: "碳排放强度", value: 0.42, unit: "tCO₂/MWh", trend: -0.08, type: .success)
    }
    .padding()
}
