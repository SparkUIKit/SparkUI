//
//  SparkTree.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/9.
//

import SwiftUI

public struct SparkTree: View {
    let options: [SparkCascaderOption]
    @Binding var selection: String? // 当前选中的节点 ID
    public var onNodeClick: ((SparkCascaderOption) -> Void)?
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(options) { option in
                    SparkTreeNode(
                        option: option,
                        selection: $selection,
                        level: 0,
                        onNodeClick: onNodeClick
                    )
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - 递归子节点
private struct SparkTreeNode: View {
    let option: SparkCascaderOption
    @Binding var selection: String?
    let level: Int
    var onNodeClick: ((SparkCascaderOption) -> Void)?
    
    @State private var isExpanded: Bool = false
    
    private var hasChildren: Bool {
        option.children != nil && !option.children!.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 节点行
            HStack(spacing: 4) {
                // 展开/折叠 箭头
                Group {
                    if hasChildren {
                        Image(systemName: "nosign") // 使用透明占位或自定义图标
                            .overlay(
                                Image(systemName: "chevron.right")
                                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                                    .font(.system(size: 10, weight: .bold))
                            )
                            .foregroundColor(.secondary)
                            .onTapGesture {
                                withAnimation(.snappy(duration: 0.2)) {
                                    isExpanded.toggle()
                                }
                            }
                    } else {
                        Spacer().frame(width: 12)
                    }
                }
                .frame(width: 20)

                // 节点内容
                Text(option.label)
                    .font(.system(size: 13))
                    .foregroundColor(selection == option.value ? .blue : .primary)
                
                Spacer()
            }
            .padding(.leading, CGFloat(level) * 16) // 层级缩进
            .frame(height: 32)
            .contentShape(Rectangle())
            .background(selection == option.value ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(4)
            .onTapGesture {
                selection = option.value
                onNodeClick?(option)
                if hasChildren {
                    withAnimation { isExpanded.toggle() }
                }
            }
            
            // 递归渲染子节点
            if hasChildren && isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(option.children!) { child in
                        SparkTreeNode(
                            option: child,
                            selection: $selection,
                            level: level + 1,
                            onNodeClick: onNodeClick
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 8)
    }
}

struct SparkTree_Previews: PreviewProvider {
    struct TreeLab: View {
        @State private var selectedNodeId: String? = "xh"
        
        let treeData = [
            SparkCascaderOption(label: "浙江省能源局", value: "zj", children: [
                SparkCascaderOption(label: "杭州市分局", value: "hz", children: [
                    SparkCascaderOption(label: "西湖区站点", value: "xh"),
                    SparkCascaderOption(label: "滨江区站点", value: "bj")
                ]),
                SparkCascaderOption(label: "宁波市分局", value: "nb", children: [
                    SparkCascaderOption(label: "海曙区站点", value: "hs"),
                    SparkCascaderOption(label: "鄞州区站点", value: "yz")
                ])
            ]),
            SparkCascaderOption(label: "江苏省能源局", value: "js", children: [
                SparkCascaderOption(label: "南京市分局", value: "nj")
            ])
        ]
        
        var body: some View {
            HStack(spacing: 0) {
                // 模拟侧边栏
                VStack(alignment: .leading) {
                    Text("组织架构").font(.headline).padding()
                    SparkTree(options: treeData, selection: $selectedNodeId) { node in
                        print("切换到站点: \(node.label)")
                    }
                }
                .frame(width: 240)
                .background(Color(.windowBackgroundColor))
                
                Divider()
                
                // 模拟主内容区
                SparkMain {
                    VStack(spacing: 20) {
                        Text("当前选择节点 ID: \(selectedNodeId ?? "无")")
                            .font(.title2)
                        
                        if selectedNodeId == "xh" {
                            Text("正在显示 [西湖区站点] 的实时负荷曲线...")
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(width: 800, height: 500)
        }
    }

    static var previews: some View {
        TreeLab()
    }
}
