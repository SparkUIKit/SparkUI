//
//  SparkTableColumn.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/9.
//

import SwiftUI

public struct SparkTableColumn<T: Identifiable>: Identifiable {
    public let id = UUID()
    public let title: String
    public let width: CGFloat? // nil 表示自适应
    public let content: (T) -> AnyView // 支持自定义单元格内容
    
    public init(title: String, width: CGFloat? = nil, @ViewBuilder content: @escaping (T) -> some View) {
        self.title = title
        self.width = width
        self.content = { AnyView(content($0)) }
    }
}
