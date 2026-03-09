//
//  SparkTable.swift
//  SparkUI
//
//  Created by 张凯杰 on 2026/3/9.
//

import SwiftUI

public struct SparkTable<T: Identifiable>: View {
    let data: [T]
    let columns: [SparkTableColumn<T>]
    public var stripe: Bool = true // 是否开启斑马纹
    
    public var body: some View {
        VStack(spacing: 0) {
            // --- 表头 ---
            HStack(spacing: 0) {
                ForEach(columns) { col in
                    Text(col.title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: col.width, alignment: .leading)
                        .padding(.horizontal, 12)
                    
                    if col.id != columns.last?.id {
                        Divider().frame(height: 14)
                    }
                }
                Spacer()
            }
            .frame(height: 40)
            .background(Color.gray.opacity(0.05))
            
            Divider()
            
            // --- 表体 ---
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                        HStack(spacing: 0) {
                            ForEach(columns) { col in
                                col.content(item)
                                    .font(.system(size: 13))
                                    .frame(width: col.width, alignment: .leading)
                                    .padding(.horizontal, 12)
                            }
                            Spacer()
                        }
                        .frame(height: 44)
                        .background(stripe && index % 2 != 0 ? Color.gray.opacity(0.02) : Color.clear)
                        
                        Divider().opacity(0.5)
                    }
                }
            }
        }
        .background(Color(.windowBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 0.5)
        )
    }
}

// 模拟业务数据模型
struct EnergyRecord: Identifiable {
    let id = UUID()
    let company: String
    let energyType: String
    let amount: Double
    let status: String // "Passed", "Pending", "Error"
}

struct SparkTable_Previews: PreviewProvider {
    static var previews: some View {
        TableLab()
    }
    
    struct TableLab: View {
        let records = [
            EnergyRecord(company: "杭州钢铁集团", energyType: "光伏发电", amount: 12500.5, status: "Passed"),
            EnergyRecord(company: "宁波镇海炼化", energyType: "风力发电", amount: 45200.0, status: "Pending"),
            EnergyRecord(company: "湖州特钢厂", energyType: "生物质能", amount: 8900.2, status: "Error"),
            EnergyRecord(company: "嘉兴光伏产业园", energyType: "光伏发电", amount: 31000.8, status: "Passed")
        ]
        
        var body: some View {
            SparkContainer {
                SparkMain {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("绿证核验清单").font(.title3).bold()
                                Text("展示浙江省内重点用能单位的绿证申领状态").font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("导出 Excel") {}.buttonStyle(.bordered)
                        }
                        
                        SparkTable(data: records, columns: [
                            SparkTableColumn(title: "企业名称", width: 200) { item in
                                Text(item.company).bold()
                            },
                            SparkTableColumn(title: "能源类型", width: 120) { item in
                                Label(item.energyType, systemImage: "leaf.fill")
                                    .foregroundColor(.green)
                            },
                            SparkTableColumn(title: "核验电量 (kWh)", width: 150) { item in
                                Text("\(item.amount, specifier: "%.1f")")
                                    .font(.system(.body, design: .monospaced))
                            },
                            SparkTableColumn(title: "状态", width: 100) { item in
                                // 这里以后可以换成你的 SparkTag 组件
                                StatusTag(status: item.status)
                            },
                            SparkTableColumn(title: "操作") { item in
                                Button("详情") { print("查看 \(item.company)") }
                                    .foregroundColor(.blue)
                            }
                        ])
                    }
                    .padding(30)
                }
            }
            .frame(width: 900, height: 500)
        }
    }
}

// 临时状态标签
struct StatusTag: View {
    let status: String
    var body: some View {
        Text(status == "Passed" ? "已通过" : (status == "Pending" ? "审核中" : "异常"))
            .font(.system(size: 11, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(statusColor.opacity(0.1))
            .foregroundColor(statusColor)
            .cornerRadius(4)
    }
    
    var statusColor: Color {
        switch status {
        case "Passed": return .green
        case "Pending": return .orange
        default: return .red
        }
    }
}
