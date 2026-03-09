//
//  SparkCascaderOption.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/9.
//

// Sources/SparkUI/Models/SparkCascaderOption.swift

import Foundation

public struct SparkCascaderOption: Identifiable, Hashable {
    public let id = UUID()
    public let label: String
    public let value: String
    public var children: [SparkCascaderOption]?
    
    public init(label: String, value: String, children: [SparkCascaderOption]? = nil) {
        self.label = label
        self.value = value
        self.children = children
    }
}
