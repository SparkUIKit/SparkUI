//
//  SparkGallery.swift.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/9.
//

import SwiftUI

public struct SparkGallery: View {
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                Section("基础组件 - SparkTag") {
                    HStack {
                        SparkTag("Primary", type: .primary)
                        SparkTag("Success", type: .success, effect: .light)
                        SparkTag("Info", type: .info, effect: .plain)
                    }
                }
                
                Section("反馈组件 - SparkMessage") {
                    Button("弹出 Info 消息") {
                        SparkMessage.show("当前系统运行平稳", type: .info)
                    }
                }
                
                // 预留你后续要开发的组件位置
                Section("开发中...") {
                    Text("SparkForm (Coming soon)")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("SparkUI 组件库预览")
        }
    }
}

#Preview {
    // 显式提供环境值，确保预览不报错
    ZStack {
        SparkGallery()
            .environment(\.sparkConfig, SparkConfig()) // 注入默认配置
            .environment(\.sparkSize, .medium)
        
        SparkMessageContainer()
    }
}
