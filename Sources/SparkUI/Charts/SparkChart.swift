//
//  SparkChart.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/9.
//

import SwiftUI
import Charts

// MARK: - 1. 配置层 (Performance Optimized)
public struct SparkChartConfig: Sendable {
    public enum ChartType: Sendable {
        case line, bar, area, pie
    }
    
    public var type: ChartType
    public var themeColor: Color
    public var smoothCurve: Bool
    public var showAxis: Bool
    public var showSelection: Bool
    public var showSymbol: Bool // 是否显示数据点标记
    
    public init(
        type: ChartType = .line,
        themeColor: Color = .blue,
        smoothCurve: Bool = true,
        showAxis: Bool = true,
        showSelection: Bool = true,
        showSymbol: Bool = false
    ) {
        self.type = type
        self.themeColor = themeColor
        self.smoothCurve = smoothCurve
        self.showAxis = showAxis
        self.showSelection = showSelection
        self.showSymbol = showSymbol
    }
}

// MARK: - 2. 核心组件
public struct SparkChart<Data: Identifiable>: View {
    let data: [Data]
    let xValue: (Data) -> String
    let yValue: (Data) -> Double
    let config: SparkChartConfig
    
    @State private var selectedX: String? = nil

    public init(
        data: [Data],
        config: SparkChartConfig = SparkChartConfig(),
        xValue: @escaping (Data) -> String,
        yValue: @escaping (Data) -> Double
    ) {
        self.data = data
        self.config = config
        self.xValue = xValue
        self.yValue = yValue
    }

    public var body: some View {
        Chart {
            ForEach(data) { item in
                renderMark(x: xValue(item), y: yValue(item))
            }
            
            // 渲染动态 Tooltip：只有在选中且非饼图时显示
            if let selectedX, config.showSelection, config.type != .pie {
                renderTooltip(for: selectedX)
            }
        }
        // 自动计算 Y 轴范围，防止图表显得太“矮”
        .chartYScale(domain: .automatic(includesZero: false))
        .chartXAxis(config.showAxis ? .visible : .hidden)
        .chartYAxis(config.showAxis ? .visible : .hidden)
        // 性能优化：将复杂的路径渲染交给 GPU
        .drawingGroup()
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    #if os(macOS)
                    .onContinuousHover { phase in
                        switch phase {
                        case .active(let location):
                            if let x: String = proxy.value(atX: location.x) {
                                selectedX = x
                            }
                        case .ended:
                            selectedX = nil
                        }
                    }
                    #else
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if let x: String = proxy.value(atX: value.location.x) {
                                    selectedX = x
                                }
                            }
                            .onEnded { _ in selectedX = nil }
                    )
                    #endif
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedX)
        .animation(.easeInOut, value: config.type)
    }

    // MARK: - 精准 Tooltip 渲染引擎
    @ChartContentBuilder
    private func renderTooltip(for selectedX: String) -> some ChartContent {
        // 1. 垂直指示线
        RuleMark(x: .value("Selected", selectedX))
            .foregroundStyle(config.themeColor.opacity(0.15))
            .lineStyle(StrokeStyle(lineWidth: 1))

        // 2. 查找对应数据点，将 Tooltip 挂载在 PointMark 上
        if let item = data.first(where: { xValue($0) == selectedX }) {
            let y = yValue(item)
            
            PointMark(x: .value("Selected", selectedX), y: .value("Y", y))
                .foregroundStyle(config.themeColor)
                .symbolSize(80)
                .annotation(position: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedX).font(.caption2).foregroundColor(.secondary)
                        Text("\(y, specifier: "%.1f")")
                            .font(.system(.body, design: .monospaced))
                            .bold()
                            .foregroundColor(config.themeColor)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            #if os(macOS)
                            .fill(Color(NSColor.windowBackgroundColor).opacity(0.95))
                            #else
                            .fill(Color(.systemBackground).opacity(0.95))
                            #endif
                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(config.themeColor.opacity(0.1), lineWidth: 0.5)
                    )
                }
        }
    }

    @ChartContentBuilder
        private func renderMark(x: String, y: Double) -> some ChartContent {
            switch config.type {
            case .line:
                let line = LineMark(x: .value("X", x), y: .value("Y", y))
                    .foregroundStyle(config.themeColor)
                    .interpolationMethod(config.smoothCurve ? .catmullRom : .linear)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                
                if config.showSymbol {
                    line.symbol(.circle) // 只有在开启时才添加 symbol
                } else {
                    line // 不添加 symbol 装饰
                }
                
            case .bar:
                BarMark(x: .value("X", x), y: .value("Y", y))
                    .foregroundStyle(config.themeColor.gradient)
                    .cornerRadius(4)
                    
            case .area:
                AreaMark(x: .value("X", x), y: .value("Y", y))
                    .foregroundStyle(config.themeColor.opacity(0.2).gradient)
                    .interpolationMethod(config.smoothCurve ? .catmullRom : .linear)
                    
            case .pie:
                if #available(iOS 17.0, macOS 14.0, *) {
                    SectorMark(
                        angle: .value("Value", y),
                        innerRadius: .ratio(0.6),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("Label", x))
                    .cornerRadius(5)
                } else {
                    BarMark(x: .value("X", x), y: .value("Y", y))
                        .foregroundStyle(by: .value("Label", x))
                }
            }
        }
}

// MARK: - 3. 预览中心
struct SparkChart_Previews: PreviewProvider {
    struct EnergySample: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
    }
    
    static let monitorData = [
        EnergySample(label: "00:00", value: 120),
        EnergySample(label: "04:00", value: 90),
        EnergySample(label: "08:00", value: 450),
        EnergySample(label: "12:00", value: 890),
        EnergySample(label: "16:00", value: 720),
        EnergySample(label: "20:00", value: 540)
    ]

    static var previews: some View {
        VStack(spacing: 30) {
            Text("SparkChart 能源监控展示").font(.title3).bold()
            
            // 1. 折线图预览
            SparkChart(data: monitorData, config: SparkChartConfig(type: .line, showSymbol: true)) { $0.label } yValue: { $0.value }
                .frame(height: 180)
            
            // 2. 环形图预览 (iOS 17+ / macOS 14+)
            SparkChart(data: monitorData, config: SparkChartConfig(type: .pie)) { $0.label } yValue: { $0.value }
                .frame(height: 180)
        }
        .padding(30)
        .background(Color(.windowBackgroundColor))
        .frame(width: 500)
    }
}
