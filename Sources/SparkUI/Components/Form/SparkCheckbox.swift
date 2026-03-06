//
//  SparkCheckbox.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

public struct SparkCheckbox: View {
    @Environment(\.sparkConfig) private var config
    @Environment(\.sparkSize) private var envSize
    
    @Binding var isOn: Bool
    private let label: String?
    private let disabled: Bool
    
    public init(
        _ isOn: Binding<Bool>,
        label: String? = nil,
        disabled: Bool = false
    ) {
        self._isOn = isOn
        self.label = label
        self.disabled = disabled
    }

    public var body: some View {
        HStack(spacing: labelSpacing) {
            ZStack {
                RoundedRectangle(cornerRadius: boxCornerRadius)
                    .stroke(borderColor, lineWidth: 1.5)
                    .frame(width: boxSize, height: boxSize)
                
                if isOn {
                    RoundedRectangle(cornerRadius: boxCornerRadius)
                        .fill(disabled ? Color.gray.opacity(0.4) : config.primaryColor)
                        .frame(width: boxSize, height: boxSize)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: checkmarkSize, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isOn)
            
            // --- 文本标签 ---
            if let label = label {
                Text(label)
                    .font(fontSize)
                    .foregroundColor(disabled ? .secondary : .primary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !disabled {
                isOn.toggle()
            }
        }
        .opacity(disabled ? 0.6 : 1.0)
    }

    // MARK: - 样式计算 (对齐 SparkTheme)
    
    private var boxSize: CGFloat {
        switch envSize {
        case .large: return 20
        case .medium: return 16
        case .small: return 14
        case .mini: return 12
        }
    }
    
    private var boxCornerRadius: CGFloat {
        envSize == .large ? 4 : 3
    }
    
    private var checkmarkSize: CGFloat {
        switch envSize {
        case .large: return 10
        case .medium: return 8
        case .small: return 7
        case .mini: return 6
        }
    }
    
    private var fontSize: Font {
        switch envSize {
        case .large: return .body
        case .medium: return .subheadline
        case .small: return .footnote
        case .mini: return .caption2
        }
    }
    
    private var borderColor: Color {
        if isOn && !disabled { return config.primaryColor }
        return Color.secondary.opacity(0.4)
    }
    
    private var labelSpacing: CGFloat { 8 }
}

#Preview {
    struct CheckboxDemo: View {
        @State private var singleVal = true
        @State private var groupVal: [String] = ["Swift"]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 25) {
                SparkCheckbox($singleVal, label: "单个开关: \(singleVal ? "开" : "关")")
                
                Divider()
                
                Text("开发语言选择 (多选):")
                HStack {
                    // 修复多选逻辑：确保 Binding 正确更新
                    CheckboxItem(title: "Swift", store: $groupVal)
                    CheckboxItem(title: "SwiftUI", store: $groupVal)
                }
            }
            .padding()
        }
    }
    
    struct CheckboxItem: View {
        let title: String
        @Binding var store: [String]
        
        var body: some View {
            SparkCheckbox(Binding(
                get: { store.contains(title) },
                set: { shouldAdd in
                    if shouldAdd {
                        if !store.contains(title) { store.append(title) }
                    } else {
                        store.removeAll { $0 == title }
                    }
                }
            ), label: title)
        }
    }
    
    return CheckboxDemo()
}
