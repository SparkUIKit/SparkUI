//
//  SparkIcon.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/9.
//

//
//  SparkIcon.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/9.
//

import SwiftUI

/// SparkIcon: 参照 Element Plus el-icon 设计的图标组件
public struct SparkIcon: View {
    private let name: String?
    private let systemName: String?
    private let color: Color?
    private let size: CGFloat?

    /// 初始化 SF Symbols 图标
    /// - Parameters:
    ///   - systemName: SF Symbols 名称
    ///   - size: 图标大小 (宽和高相等)
    ///   - color: 图标颜色，为 nil 时继承父容器颜色
    public init(systemName: String, size: CGFloat? = nil, color: Color? = nil) {
        self.systemName = systemName
        self.name = nil
        self.size = size
        self.color = color
    }
    
    /// 初始化自定义图片资源图标
    /// - Parameters:
    ///   - name: Assets 中的图片名称
    ///   - size: 图标大小
    ///   - color: 渲染颜色 (仅对 Template 类型的图片有效)
    public init(name: String, size: CGFloat? = nil, color: Color? = nil) {
        self.name = name
        self.systemName = nil
        self.size = size
        self.color = color
    }

    public var body: some View {
        Group {
            if let sysName = systemName {
                Image(systemName: sysName)
                    .resizable()
            } else if let assetName = name {
                Image(assetName)
                    .resizable()
            }
        }
        .aspectRatio(contentMode: .fit)
        // 如果未指定 size，则不强制设置 frame，允许其自适应容器
        .frame(width: size, height: size)
        // 如果未指定 color，则不设置 foregroundColor，允许其继承环境颜色
        .modifyIf(color != nil) {
            $0.foregroundColor(color)
        }
    }
}

// MARK: - 辅助扩展
extension View {
    @ViewBuilder
    func modifyIf<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - 预览
struct SparkIcon_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // 1. 基础用法
            SparkIcon(systemName: "bolt.fill")
            
            // 2. 指定大小和颜色
            SparkIcon(systemName: "leaf.fill", size: 40, color: .green)
            
            // 3. 继承颜色测试
            HStack {
                SparkIcon(systemName: "gearshape.fill", size: 24)
                Text("系统设置")
            }
            .foregroundColor(.blue) // 图标将自动变蓝
        }
        .padding()
    }
}
