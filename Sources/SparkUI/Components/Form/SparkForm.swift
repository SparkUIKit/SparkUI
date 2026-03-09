//
//  SparkForm.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/9.
//

import SwiftUI

/// 表单排列方式
public enum SparkFormLabelPosition: Sendable {
    case left, right, top
}

public struct SparkForm<Content: View>: View {
    public var labelWidth: CGFloat = 80
    public var labelPosition: SparkFormLabelPosition = .right
    let content: Content
    
    public init(
        labelWidth: CGFloat = 80,
        labelPosition: SparkFormLabelPosition = .right,
        @ViewBuilder content: () -> Content
    ) {
        self.labelWidth = labelWidth
        self.labelPosition = labelPosition
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            content
        }
        // 将配置通过环境传给 SparkFormItem
        .environment(\.sparkFormLabelWidth, labelWidth)
        .environment(\.sparkFormLabelPosition, labelPosition)
    }
}

// MARK: - SparkFormItem

public struct SparkFormItem<Content: View>: View {
    let label: String
    var required: Bool = false
    var error: String? = nil
    let content: Content
    
    @Environment(\.sparkFormLabelWidth) var envLabelWidth
    @Environment(\.sparkFormLabelPosition) var envLabelPosition
    
    public init(
        _ label: String,
        required: Bool = false,
        error: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.label = label
        self.required = required
        self.error = error
        self.content = content()
    }
    
    public var body: some View {
        Group {
            if envLabelPosition == .top {
                VStack(alignment: .leading, spacing: 8) {
                    labelView
                    contentView
                }
            } else {
                HStack(alignment: .top, spacing: 12) {
                    labelView
                        .frame(width: envLabelWidth, alignment: envLabelPosition == .right ? .trailing : .leading)
                        .padding(.top, 8)
                    contentView
                }
            }
        }
    }
    
    private var labelView: some View {
        HStack(spacing: 2) {
            if required {
                Text("*").foregroundColor(.red)
            }
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.primary.opacity(0.8))
        }
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 4) {
            content
            if let error = error {
                Text(error)
                    .font(.caption2)
                    .foregroundColor(.red)
                    .transition(.opacity)
            }
        }
    }
}

// --- Environment Keys ---
private struct SparkFormLabelWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 80
}
private struct SparkFormLabelPositionKey: EnvironmentKey {
    static let defaultValue: SparkFormLabelPosition = .right
}

extension EnvironmentValues {
    var sparkFormLabelWidth: CGFloat {
        get { self[SparkFormLabelWidthKey.self] }
        set { self[SparkFormLabelWidthKey.self] = newValue }
    }
    var sparkFormLabelPosition: SparkFormLabelPosition {
        get { self[SparkFormLabelPositionKey.self] }
        set { self[SparkFormLabelPositionKey.self] = newValue }
    }
}

struct SparkForm_Previews: PreviewProvider {
    struct FormLab: View {
        @State private var companyName = ""
        @State private var region: [String] = []
        @State private var energyValue = ""
        
        var body: some View {
            SparkContainer {
                SparkMain {
                    VStack(alignment: .leading, spacing: 25) {
                        Text("新增能耗报送").font(.title2).bold()
                        
                        SparkForm(labelWidth: 100, labelPosition: .right) {
                            SparkFormItem("单位名称", required: true) {
                                SparkAutocomplete(
                                    text: $companyName,
                                    placeholder: "搜索单位...",
                                    suggestions: ["浙江省电力公司", "杭州能源集团", "宁波石化"]
                                )
                            }
                            
                            SparkFormItem("所属区域", required: true) {
                                SparkCascader(
                                    selection: $region,
                                    options: [
                                        SparkCascaderOption(label: "浙江省", value: "zj", children: [
                                            SparkCascaderOption(label: "杭州市", value: "hz")
                                        ])
                                    ]
                                )
                            }
                            
                            SparkFormItem("本月耗电量", error: energyValue.isEmpty ? "请输入电量值" : nil) {
                                SparkInput(text: $energyValue, placeholder: "请输入数值", suffixIcon: "bolt.fill")
                            }
                        }
                        .frame(maxWidth: 500)
                        
                        HStack {
                            Spacer().frame(width: 112) // 对齐 labelWidth + spacing
                            Button("提交报送") {}.buttonStyle(.borderedProminent)
                            Button("重置") {}.buttonStyle(.bordered)
                        }
                    }
                    .padding(40)
                }
            }
            .frame(width: 800, height: 500)
        }
    }

    static var previews: some View {
        FormLab()
    }
}
