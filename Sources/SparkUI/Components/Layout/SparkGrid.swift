//
//  SparkGrid.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/6.
//

import SwiftUI

public enum SparkJustify: Sendable, CaseIterable, Hashable {
    case start, center, end
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct SparkGridLayout: Layout {
    let gutter: CGFloat
    let justify: SparkJustify
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let totalWidth = bounds.width
        // 24个栅格，23个间距
        let unitWidth = (totalWidth - (gutter * 23)) / 24
        
        var xOffset = bounds.minX
        
        // 简单的对齐逻辑计算
        for subview in subviews {
            let span = subview[SparkSpanKey.self]
            let offset = subview[SparkOffsetKey.self]
            
            let colWidth = CGFloat(span) * unitWidth + CGFloat(max(0, span - 1)) * gutter
            let offsetWidth = CGFloat(offset) * (unitWidth + gutter)
            
            let currentX = xOffset + offsetWidth
            subview.place(
                at: CGPoint(x: currentX, y: bounds.minY),
                proposal: ProposedViewSize(width: colWidth, height: proposal.height)
            )
            
            xOffset = currentX + colWidth + gutter
        }
    }
}

@available(iOS 16.0, macOS 13.0, *)
public struct SparkRow<Content: View>: View {
    private let gutter: CGFloat
    private let justify: SparkJustify
    private let content: Content
    
    public init(gutter: CGFloat = 0, justify: SparkJustify = .start, @ViewBuilder content: () -> Content) {
        self.gutter = gutter
        self.justify = justify
        self.content = content()
    }
    
    public var body: some View {
        SparkGridLayout(gutter: gutter, justify: justify) {
            content
        }
    }
}

@available(iOS 16.0, macOS 13.0, *)
public struct SparkCol<Content: View>: View {
    private let span: Int
    private let offset: Int
    private let content: Content
    
    public init(span: Int = 24, offset: Int = 0, @ViewBuilder content: () -> Content) {
        self.span = max(1, min(span, 24))
        self.offset = max(0, min(offset, 23))
        self.content = content()
    }
    
    public var body: some View {
        content
            .layoutValue(key: SparkSpanKey.self, value: span)
            .layoutValue(key: SparkOffsetKey.self, value: offset)
    }
}

struct SparkSpanKey: LayoutValueKey { static let defaultValue: Int = 24 }
struct SparkOffsetKey: LayoutValueKey { static let defaultValue: Int = 0 }

#Preview("SparkGrid 24栅格说明书") {
    if #available(iOS 16.0, macOS 13.0, *) {
        ScrollView {
            VStack(spacing: 40) {
                
                // --- 1. 基础等分 ---
                VStack(alignment: .leading) {
                    Text("1. 基础等分 (8+8+8)").font(.caption).foregroundColor(.secondary)
                    SparkRow(gutter: 8) {
                        ForEach(0..<3) { i in
                            SparkCol(span: 8) {
                                Rectangle()
                                    .fill(.blue.opacity(0.6))
                                    .frame(height: 40)
                                    .overlay(Text("8").whiteCaption())
                            }
                        }
                    }
                }

                // --- 2. 混合比例 ---
                VStack(alignment: .leading) {
                    Text("2. 混合比例 (4+12+8)").font(.caption).foregroundColor(.secondary)
                    SparkRow(gutter: 8) {
                        SparkCol(span: 4) {
                            Rectangle().fill(.orange).frame(height: 40).overlay(Text("4").whiteCaption())
                        }
                        SparkCol(span: 12) {
                            Rectangle().fill(.orange.opacity(0.8)).frame(height: 40).overlay(Text("12").whiteCaption())
                        }
                        SparkCol(span: 8) {
                            Rectangle().fill(.orange.opacity(0.6)).frame(height: 40).overlay(Text("8").whiteCaption())
                        }
                    }
                }

                // --- 3. 偏移量 (Offset) ---
                VStack(alignment: .leading) {
                    Text("3. 偏移量 (Span 6 + Offset 6 + Span 12)").font(.caption).foregroundColor(.secondary)
                    SparkRow(gutter: 8) {
                        SparkCol(span: 6) {
                            Rectangle().fill(.purple).frame(height: 40).overlay(Text("6").whiteCaption())
                        }
                        SparkCol(span: 12, offset: 6) {
                            Rectangle().fill(.purple.opacity(0.7)).frame(height: 40).overlay(Text("Off 6, Span 12").whiteCaption())
                        }
                    }
                }

                // --- 4. 真实业务场景：表单预览 ---
                VStack(alignment: .leading) {
                    Text("4. 业务场景：自适应表单布局").font(.caption).foregroundColor(.secondary)
                    SparkRow(gutter: 16) {
                        ForEach(0..<2) { _ in
                            SparkCol(span: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("标签名").font(.system(size: 12))
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.gray.opacity(0.3))
                                        .frame(height: 36)
                                }
                            }
                        }
                    }
                }
                
            }
            .padding()
        }
    } else {
        Text("需要 iOS 16+")
    }
}

// 辅助扩展，让预览代码更干净
extension View {
    func whiteCaption() -> some View {
        self.foregroundColor(.white).font(.system(size: 10, weight: .bold))
    }
}
