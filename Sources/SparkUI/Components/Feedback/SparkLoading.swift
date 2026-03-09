//
//  SparkLoading.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

public struct SparkLoading: View {
    @Environment(\.sparkConfig) private var config
    
    private let text: String?
    private let type: SparkType
    private let fullScreen: Bool
    
    @State private var isAnimating = false
    
    public init(
        _ text: String? = nil,
        type: SparkType = .primary,
        fullScreen: Bool = false
    ) {
        self.text = text
        self.type = type
        self.fullScreen = fullScreen
    }
    
    public var body: some View {
        ZStack {
            if fullScreen {
                Color.white.opacity(0.7)
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 12) {
                // 加载旋转圆环
                loadingIndicator
                
                if let text = text {
                    Text(text)
                        .font(.system(size: 14))
                        .foregroundColor(loadingColor)
                }
            }
            .padding(20)
            .background(
                fullScreen ? Color.clear : Color.white.opacity(0.9)
            )
            .cornerRadius(config.cornerRadius)
        }
    }
    
    // 自定义旋转动画组件
    private var loadingIndicator: some View {
        ZStack {
            // 背景底圈
            Circle()
                .stroke(loadingColor.opacity(0.2), lineWidth: 3)
                .frame(width: 30, height: 30)
            
            // 旋转的进度条
            Circle()
                .trim(from: 0, to: 0.25)
                .stroke(loadingColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 30, height: 30)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        isAnimating = true
                    }
                }
        }
    }
    
    private var loadingColor: Color {
        switch type {
        case .primary: return config.primaryColor
        case .success: return config.successColor
        case .warning: return config.warningColor
        case .danger: return config.dangerColor
        case .info: return config.infoColor
        case .default: return .gray
        }
    }
}

#Preview {
    VStack(spacing: 50) {
        
        // 1. 区域加载 (Nested Loading)
        GroupBox("卡片局部加载") {
            ZStack {
                // 模拟数据内容
                VStack(alignment: .leading, spacing: 10) {
                    Text("订单列表").font(.headline)
                    ForEach(0..<3) { _ in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 20)
                    }
                }
                .padding()
                .blur(radius: 2) // 加载时内容模糊
                
                // 覆盖加载层
                SparkLoading("拼命加载中...")
            }
            .frame(height: 150)
            .clipped()
        }
        
        // 2. 不同颜色和尺寸
        GroupBox("样式变体") {
            HStack(spacing: 40) {
                SparkLoading(type: .success)
                SparkLoading(type: .warning)
                SparkLoading(type: .danger)
            }
            .padding()
        }
        
        // 3. 全屏加载切换
        LoadingControlDemo()
    }
    .padding()
}

struct LoadingControlDemo: View {
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            Button("触发全屏加载 (3秒)") {
                isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isLoading = false
                }
            }
            .buttonStyle(.borderedProminent)
            
            if isLoading {
                // 全屏模式通常挂在最外层 ZStack
                SparkLoading("系统处理中", type: .primary, fullScreen: true)
                    .zIndex(999)
            }
        }
    }
}
