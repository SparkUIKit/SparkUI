//
//  SparkResult.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/6.
//

import SwiftUI

public struct SparkResult<Extra: View>: View {
    
    public enum Status {
        case success, error, warning, info
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .warning: return .orange
            case .info: return .blue
            }
        }
    }
    
    private let status: Status
    private let title: String
    private let subTitle: String?
    private let extra: Extra?
    
    @State private var isAnimating: Bool = false
    
    public init(
        status: Status,
        title: String,
        subTitle: String? = nil,
        @ViewBuilder extra: () -> Extra?
    ) {
        self.status = status
        self.title = title
        self.subTitle = subTitle
        self.extra = extra()
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            Image(systemName: status.icon)
                .font(.system(size: 72, weight: .medium))
                .foregroundColor(status.color)
                .scaleEffect(isAnimating ? 1.0 : 0.5)
                .opacity(isAnimating ? 1.0 : 0.0)
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                if let sub = subTitle {
                    Text(sub)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .lineSpacing(4)
                }
            }
            
            if let extraView = extra {
                extraView
                    .padding(.top, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) {
                isAnimating = true
            }
        }
    }
}

extension SparkResult where Extra == EmptyView {
    public init(status: Status, title: String, subTitle: String? = nil) {
        self.status = status
        self.title = title
        self.subTitle = subTitle
        self.extra = nil
    }
}

#Preview("全状态预览") {
    ScrollView {
        VStack(spacing: 0) {
            // 情况 A：提供 Extra 视图 (编译器推断 Extra 为 HStack)
            SparkResult(
                status: .success,
                title: "支付成功",
                subTitle: "您的订单已处理完成。"
            ) {
                HStack(spacing: 16) {
                    Button("查看订单") {}.buttonStyle(.bordered)
                    Button("返回首页") {}.buttonStyle(.borderedProminent)
                }
            }
            
            Divider()
            
            // 情况 B：不提供 Extra 视图 (编译器使用 extension，推断 Extra 为 EmptyView)
            SparkResult(
                status: .warning,
                title: "存储空间不足",
                subTitle: "您的云端存储空间已耗尽。"
            )
        }
    }
}
