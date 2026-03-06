//
//  SparkDialog.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/5.
//

import SwiftUI

// 1. 修复 UIColor 报错的关键：导入 UIKit
#if canImport(UIKit)
import UIKit
#endif

public struct SparkDialog<Content: View, Footer: View>: View {
    @Environment(\.sparkConfig) private var config
    
    @Binding var isPresented: Bool
    let title: String
    let width: CGFloat
    let showClose: Bool
    let content: Content
    let footer: Footer
    
    public init(
        isPresented: Binding<Bool>,
        title: String = "提示",
        width: CGFloat = 400,
        showClose: Bool = true,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self._isPresented = isPresented
        self.title = title
        self.width = width
        self.showClose = showClose
        self.content = content()
        self.footer = footer()
    }
    
    public init(
        isPresented: Binding<Bool>,
        title: String = "提示",
        width: CGFloat = 400,
        showClose: Bool = true,
        @ViewBuilder content: () -> Content
    ) where Footer == EmptyView {
        self._isPresented = isPresented
        self.title = title
        self.width = width
        self.showClose = showClose
        self.content = content()
        self.footer = EmptyView()
    }

    public var body: some View {
        ZStack {
            if isPresented {
                // 1. 遮罩层
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { dismiss() }
                    .transition(.opacity)
                
                // 2. 对话框主体
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(title)
                            .font(.system(size: 18, weight: .medium))
                        Spacer()
                        if showClose {
                            Button(action: dismiss) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    
                    ScrollView {
                        VStack(alignment: .leading) {
                            content
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    .frame(maxHeight: 400)
                    
                    if Footer.self != EmptyView.self {
                        HStack(spacing: 12) {
                            Spacer()
                            footer
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                    }
                }
                .frame(maxWidth: width)
                .background(
                    RoundedRectangle(cornerRadius: config.cornerRadius)
                        .fill(Color(white: 1.0)) // 强制白色底，避免透视
                )
                .padding(.horizontal, 30) // 确保在小窗口下两侧有呼吸感
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
                .zIndex(1)
            }
        }
        .ignoresSafeArea()
    }
    
    private func dismiss() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            isPresented = false
        }
    }
}


#Preview {
    DialogPreviewContainer()
}

struct DialogPreviewContainer: View {
    @State private var showBasic = false
    @State private var showForm = false
    @State private var username = ""
    
    var body: some View {
        ZStack {
            // 背景模拟真实 App 页面
            VStack(spacing: 0) {
                HStack {
                    Text("控制面板").font(.title2).bold()
                    Spacer()
                    Image(systemName: "person.circle").font(.title2)
                }
                .padding()
                .background(Color.white)
                
                List {
                    Section("交互测试") {
                        Button("打开删除确认") {
                            withAnimation { showBasic = true }
                        }
                        Button("编辑个人资料") {
                            withAnimation { showForm = true }
                        }
                    }
                }
            }
            
            // 基础对话框
            SparkDialog(isPresented: $showBasic, title: "确认删除") {
                Text("此操作不可撤销，您确定要删除该条记录吗？")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            } footer: {
                Button("取消") { showBasic = false }.buttonStyle(.plain)
                Button("删除") { showBasic = false }.foregroundColor(.red).buttonStyle(.bordered)
            }
            
            // 表单对话框
            SparkDialog(isPresented: $showForm, title: "编辑资料") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("昵称").font(.caption).foregroundColor(.gray)
                    TextField("请输入昵称", text: $username)
                        .textFieldStyle(.roundedBorder)
                    SparkAlert(title: "提示", description: "昵称支持中英文，不包含特殊字符。", type: .primary)
                }
                .padding(.vertical, 5)
            } footer: {
                Button("保存") { showForm = false }.buttonStyle(.borderedProminent)
            }
        }
        // 修正预览：强制给一个手机尺寸的背景
        .frame(width: 393, height: 452)
        .background(Color.gray.opacity(0.1))
    }
}
