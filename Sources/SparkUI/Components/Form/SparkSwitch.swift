//
//  SparkInput.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//
import SwiftUI

public struct SparkSwitch: View {
    @Environment(\.sparkConfig) private var config
    @Environment(\.sparkSize) private var envSize
    
    @Binding var isOn: Bool
    
    public var disabled: Bool
    public var loading: Bool
    private var manualSize: SparkSize?
    
    public var activeText: String? = nil
    public var inactiveText: String? = nil
    
    private var finalSize: SparkSize { manualSize ?? envSize }

    public init(isOn: Binding<Bool>,
                size: SparkSize? = nil,
                disabled: Bool = false,
                loading: Bool = false,
                activeText: String? = nil,
                inactiveText: String? = nil) {
        self._isOn = isOn
        self.manualSize = size
        self.disabled = disabled
        self.loading = loading
        self.activeText = activeText
        self.inactiveText = inactiveText
    }

    private var specs: (width: CGFloat, height: CGFloat, knobSize: CGFloat, offset: CGFloat) {
        let h: CGFloat
        switch finalSize {
        case .large:  h = 28
        case .medium: h = 24
        case .small:  h = 20
        case .mini:   h = 16
        }
        let w = h * 1.85
        let k = h - 4
        let off = (w - h) / 2
        return (w, h, k, off)
    }

    public var body: some View {
        HStack(spacing: 8) {
            // 左侧文字
            if let inactiveText = inactiveText {
                Text(inactiveText)
                    .font(.system(size: specs.height * 0.55))
                    .foregroundColor(!isOn ? config.primaryColor : .secondary)
            }
            
            Button {
                guard !disabled && !loading else { return }
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    isOn.toggle()
                }
                #if os(iOS)
                UISelectionFeedbackGenerator().selectionChanged()
                #endif
            } label: {
                ZStack {
                    // 背景轨道
                    Capsule()
                        .fill(isOn ? config.primaryColor : Color.secondary.opacity(0.2))
                        .frame(width: specs.width, height: specs.height)
                    
                    // 滑块
                    ZStack {
                        Circle()
                            .fill(.white)
                            .shadow(color: .black.opacity(0.12), radius: 1.5, x: 0, y: 1)
                        
                        if loading {
                            Circle()
                                .trim(from: 0, to: 0.7)
                                .stroke(isOn ? config.primaryColor : Color.gray, lineWidth: 1.5)
                                .frame(width: specs.knobSize * 0.7, height: specs.knobSize * 0.7)
                                .rotationEffect(.degrees(loading ? 360 : 0))
                                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: loading)
                        }
                    }
                    .frame(width: specs.knobSize, height: specs.knobSize)
                    .offset(x: isOn ? specs.offset : -specs.offset)
                }
            }
            .buttonStyle(.plain)
            .disabled(disabled || loading)
            .opacity(disabled ? 0.4 : 1.0)
            
            // 右侧文字
            if let activeText = activeText {
                Text(activeText)
                    .font(.system(size: specs.height * 0.55))
                    .foregroundColor(isOn ? config.primaryColor : .secondary)
            }
        }
    }
}

// --- 综合状态预览 ---

#Preview {
    struct SwitchPreviewContainer: View {
        @State private var isOn1 = true
        @State private var isOn2 = false
        @State private var isOn3 = true
        
        var body: some View {
            VStack(spacing: 30) {
                // 1. 基础尺寸对比
                GroupBox("基础尺寸 (Sizes)") {
                    VStack(alignment: .leading, spacing: 15) {
                        SparkSwitch(isOn: $isOn1, size: .large, activeText: "Large")
                        SparkSwitch(isOn: $isOn1, size: .medium, activeText: "Medium")
                        SparkSwitch(isOn: $isOn1, size: .small, activeText: "Small")
                        SparkSwitch(isOn: $isOn1, size: .mini, activeText: "Mini")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                }

                // 2. 特殊状态对比
                GroupBox("特殊状态 (States)") {
                    VStack(alignment: .leading, spacing: 15) {
                        SparkSwitch(isOn: $isOn2, activeText: "正常状态")
                        SparkSwitch(isOn: .constant(true), loading: true, activeText: "加载中 (Loading)")
                        SparkSwitch(isOn: .constant(false), disabled: true, inactiveText: "禁用 (Disabled)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                }
                
                // 3. 完整文字模式
                GroupBox("语义化文本 (Text Labels)") {
                    SparkSwitch(
                        isOn: $isOn3,
                        activeText: "按月续费",
                        inactiveText: "按年续费"
                    )
                    .padding(.vertical, 8)
                }
            }
            .padding()
        }
    }
    
    return ScrollView {
        SwitchPreviewContainer()
    }
}
