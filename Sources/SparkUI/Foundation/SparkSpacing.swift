//
//  SparkSpacing.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

public enum SparkSpacing {
    /// 2pt - 极小间距
    public static let xxs: CGFloat = 2
    /// 4pt - 微小间距
    public static let xs: CGFloat = 4
    /// 8pt - 小间距 (组件内元素)
    public static let s: CGFloat = 8
    /// 12pt - 中小间距
    public static let m: CGFloat = 12
    /// 16pt - 标准间距 (页面边距)
    public static let l: CGFloat = 16
    /// 24pt - 大间距 (区块分割)
    public static let xl: CGFloat = 24
    /// 32pt - 极大间距
    public static let xxl: CGFloat = 32
}

// 扩展方便调用
public extension View {
    func sparkPadding(_ spacing: CGFloat) -> some View {
        self.padding(spacing)
    }
}
