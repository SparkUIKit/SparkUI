//
//  SparkCascader.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/9.
//

import SwiftUI

public struct SparkCascader: View {
    @Binding var selection: [String]
    public var placeholder: String = "请选择"
    public var options: [SparkCascaderOption]
    
    @State private var isShowingPicker = false
    @State private var activePath: [SparkCascaderOption] = []
    
    // 计算属性：双向绑定显示文本与清除逻辑
    private var displayString: Binding<String> {
        Binding(
            get: {
                findLabels(for: selection, in: options).joined(separator: " / ")
            },
            set: { newValue in
                if newValue.isEmpty {
                    selection = []
                    activePath = []
                }
            }
        )
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SparkInput(
                text: displayString,
                placeholder: placeholder,
                suffixIcon: isShowingPicker ? "chevron.up" : "chevron.down"
            )
            .overlay(
                // 拦截层：避开右侧清除按钮
                Color.white.opacity(0.001)
                    .onTapGesture {
                        isShowingPicker.toggle()
                    }
                    .padding(.trailing, 60)
            )
            // 核心修复：使用 popover 替代 overlay
            // 这样面板会渲染在独立窗口层，解决所有遮挡和裁剪问题
            .popover(isPresented: $isShowingPicker, arrowEdge: .bottom) {
                CascaderPanelView(
                    options: options,
                    activePath: $activePath,
                    onFinalSelect: { path in
                        self.selection = path.map { $0.value }
                        self.isShowingPicker = false
                    }
                )
                // 移除 macOS popover 默认的背景和内边距，使其看起来像原生菜单
                .background(VisualEffectView(material: .popover, blendingMode: .withinWindow))
            }
        }
        .frame(height: 36)
    }
    
    private func findLabels(for values: [String], in currentOptions: [SparkCascaderOption]) -> [String] {
        guard let first = values.first else { return [] }
        if let match = currentOptions.first(where: { $0.value == first }) {
            var result = [match.label]
            if values.count > 1, let children = match.children {
                result.append(contentsOf: findLabels(for: Array(values.dropFirst()), in: children))
            }
            return result
        }
        return []
    }
}

// MARK: - 视觉效果适配 (解决 macOS 毛玻璃感)
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - 面板视图
private struct CascaderPanelView: View {
    let options: [SparkCascaderOption]
    @Binding var activePath: [SparkCascaderOption]
    let onFinalSelect: ([SparkCascaderOption]) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            columnView(for: options, level: 0)
            
            ForEach(0..<activePath.count, id: \.self) { index in
                if let subOptions = activePath[index].children, !subOptions.isEmpty {
                    Divider().frame(height: 220)
                    columnView(for: subOptions, level: index + 1)
                }
            }
        }
        .fixedSize()
        // 移除多余的阴影和背景，由 Popover 容器承载
    }
    
    private func columnView(for currentOptions: [SparkCascaderOption], level: Int) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(currentOptions) { option in
                    HStack {
                        Text(option.label)
                            .font(.system(size: 13))
                        Spacer()
                        if option.children != nil {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 9, weight: .bold))
                                .opacity(0.5)
                        }
                    }
                    .padding(.horizontal, 10)
                    .frame(width: 150, height: 32)
                    .background(isOptionActive(option, at: level) ? Color.blue.opacity(0.1) : Color.clear)
                    .foregroundColor(isOptionActive(option, at: level) ? .blue : .primary)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        handleTap(option, at: level)
                    }
                }
            }
            .padding(4)
        }
        .frame(height: 220)
    }
    
    private func isOptionActive(_ option: SparkCascaderOption, at level: Int) -> Bool {
        activePath.count > level && activePath[level].id == option.id
    }
    
    private func handleTap(_ option: SparkCascaderOption, at level: Int) {
        if activePath.count > level {
            activePath.removeSubrange(level..<activePath.count)
        }
        activePath.append(option)
        
        if option.children == nil || option.children!.isEmpty {
            onFinalSelect(activePath)
        }
    }
}

// MARK: - 预览
struct SparkCascader_Previews: PreviewProvider {
    struct CascaderLab: View {
        @State private var selectedOrgPath: [String] = ["zj", "hz", "xh"]
        
        let energyOrgData = [
            SparkCascaderOption(label: "浙江省能源局", value: "zj", children: [
                SparkCascaderOption(label: "杭州市发改委", value: "hz", children: [
                    SparkCascaderOption(label: "西湖区能源办", value: "xh"),
                    SparkCascaderOption(label: "滨江区能源办", value: "bj")
                ]),
                SparkCascaderOption(label: "宁波市发改委", value: "nb", children: [
                    SparkCascaderOption(label: "海曙区管理站", value: "hs")
                ])
            ]),
            SparkCascaderOption(label: "江苏省能源局", value: "js")
        ]
        
        var body: some View {
            SparkContainer {
                SparkMain {
                    VStack(alignment: .leading, spacing: 30) {
                        Text("级联选择器 (Popover 模式)").font(.headline)
                        
                        SparkCascader(
                            selection: $selectedOrgPath,
                            options: energyOrgData
                        )
                        .frame(width: 320)
                        
                        // 测试遮挡场景：下面放一个色块
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 100)
                            .overlay(Text("这一块不会遮挡弹出面板").font(.caption))
                    }
                    .padding(100)
                }
            }
            .frame(width: 850, height: 500)
        }
    }

    static var previews: some View {
        CascaderLab()
    }
}
