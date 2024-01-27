//
//  StatsChartView.swift
//  BallNoLie
//
//  Created by Sharan Thakur on 27/01/24.
//

import Charts
import SwiftUI

struct StatsChartView: View {
    var playerStats: [
        PlayerStats
    ]
    
    init(playerStats: [PlayerStats]) {
        self.playerStats = playerStats
    }
    
    @State private var statType: StatType = .ast
    
    var body: some View {
        NavigationStack {
            Chart(chartData()) { data in
                LineMark(
                    x: .value("", data.name),
                    y: .value(data.key, data.value)
                )
                .foregroundStyle(.brown)
                
                BarMark(
                    x: .value("", data.name),
                    y: .value(data.key, data.value),
                    stacking: .unstacked
                )
                .foregroundStyle(.cyan)
            }
            .toolbar {
                Picker("", selection: $statType) {
                    ForEach(StatType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                            .tag(type)
                    }
                }
            }
        }
    }
    
    func chartData() -> [ChartData] {
        playerStats.map { stat in
            switch statType {
            case .ast:
                ChartData(key: statType.rawValue, value: stat.ast ?? (0...10).randomElement() ?? -1, name: stat.player.firstName)
            case .blk:
                ChartData(key: statType.rawValue, value: stat.blk, name: stat.player.firstName)
            case .fg:
                ChartData(key: statType.rawValue, value: stat.fgPctValue * 100, name: stat.player.firstName)
            case .ft:
                ChartData(key: statType.rawValue, value: stat.ftPctValue * 100, name: stat.player.firstName)
            case .fg3:
                ChartData(key: statType.rawValue, value: stat.fg3PctValue * 100, name: stat.player.firstName)
            case .pts:
                ChartData(key: statType.rawValue, value: stat.pts, name: stat.player.firstName)
            case .rebounds:
                ChartData(key: statType.rawValue, value: stat.reb, name: stat.player.firstName)
            case .defReb:
                ChartData(key: statType.rawValue, value: stat.dreb, name: stat.player.firstName)
            case .offReb:
                ChartData(key: statType.rawValue, value: stat.oreb, name: stat.player.firstName)
            }
        }.sorted {
            $0.name < $1.name
        }
    }
    
    struct ChartData: Identifiable {
        let id = UUID()
        let key: String
        let value: Double
        let name: String
        
        init(key: String, value: Double, name: String) {
            self.key = key
            self.value = value
            self.name = name
        }
        
        init(key: String, value: Int, name: String) {
            self.init(key: key, value: Double(value), name: name)
        }
    }
    
    enum StatType: String, CaseIterable {
        case ast = "Assists"
        case blk = "Blocks"
        case fg = "Field Goals"
        case ft = "Free Throws"
        case fg3 = "Three Pointers"
        case pts = "Points Scored"
        case rebounds = "Rebounds"
        case defReb = "Defensive Rebounds"
        case offReb = "Offesnsive Rebounds"
    }
}

#Preview {
    StatsChartView(
        playerStats:
            Array(
                repeating:
                        .dummy,
                count: 10
            )
    )
}
