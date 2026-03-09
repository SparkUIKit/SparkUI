//
//  SparkGallery.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/9.
//

import SwiftUI

public struct SparkGallery: View {
    @State private var isEcoMode = false
    @State private var mockValue: Double = 1284.5
    
    // 模拟能源绿主题
    private var ecoConfig: SparkConfig {
        var config = SparkConfig()
        config.primaryColor = Color(red: 0.1, green: 0.7, blue: 0.4)
        config.cornerRadius = 16
        return config
    }
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                Section("交互演示") {
                    Toggle("绿色能源模式 (生态绿)", isOn: $isEcoMode)
                    Button("模拟实时数据刷新") {
                        // 随机增减数值以测试滚动动画
                        mockValue += Double.random(in: -50...100)
                    }
                }
                
                Section("能源监控卡片 (复合组件)") {
                    VStack(spacing: 16) {
                        SparkStatCard(
                            title: "当日实时负荷",
                            value: mockValue,
                            unit: "MW",
                            trend: 0.05,
                            type: .primary
                        )
                        
                        SparkStatCard(
                            title: "清洁能源消纳占比",
                            value: 82.4,
                            unit: "%",
                            trend: -0.02,
                            type: .success
                        )
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("SparkUI Gallery")
            // 核心：动态注入配置，让子组件感知主题变化
            .sparkConfig(isEcoMode ? ecoConfig : SparkConfig())
            .animation(.easeInOut, value: isEcoMode)
        }
    }
}
