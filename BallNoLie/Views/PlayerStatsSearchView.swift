//
//  PlayerStatsSearchView.swift
//  BallNoLie
//
//  Created by Sharan Thakur on 27/01/24.
//

import SwiftUI

struct PlayerStatsSearchView: View {
    @State private var stats = PlayerStatsList(data: [], meta: .default)
    @State private var page = 0
    
    @State private var showAddView = true
    
    @State private var showPopUp = false
    @State private var popUpText = ""
    @State private var popUpPrompt = "Season"
    
    @State private var buttonAction: (() -> Void)?
    
    @State private var seasons = Set<Int>([2023, 2024])
    @State private var players = Array<Player>()
    
    @State private var showAddPlayer = false
    @State private var showError = false
    @State private var isBusy = false
    @State private var appError: AppError?
    
    var body: some View {
        ZStack {
            if showAddView {
                addView()
                    .toolbar {
                        ToolbarItem {
                            Button("Stats") {
                                withAnimation {
                                    showAddView = false
                                }
                            }
                        }
                    }
            } else {
                dataView()
                    .overlay(alignment: .center) {
                        if stats.data.isEmpty {
                            ContentUnavailableView {
                                Label("No Stats Added", systemImage: "person.fill")
                            } description: {
                                Text("Please add Player Stats")
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItem {
                            Button("Add", systemImage: "plus") {
                                withAnimation {
                                    showAddView = true
                                }
                            }
                        }
                    }
            }
        }
        .fullScreenCover(isPresented: $showAddPlayer) {
            NavigationStack {
                PlayersScreen { player in
                    players.insert(player, at: 0)
                    players.sort()
                    showAddPlayer = false
                }
                .toolbar {
                    Button("Close", role: .cancel) {
                        showAddPlayer = false
                    }
                }
            }
        }
        .alert(isPresented: $showError, error: appError) { _ in
            Button("Okay", role: .cancel) {
                
            }
        } message: { error in
            Text(error.errorDescription ?? error.localizedDescription)
        }
        .navigationTitle("Player Stats 📊")
    }
    
    @ViewBuilder
    func addView() -> some View {
        Form {
            Section("Season") {
                List(Array(seasons).sorted(), id: \.self) { s in
                    Text(s.description)
                        .swipeActions {
                            Button("Delete", role: .destructive) {
                                seasons.remove(s)
                            }
                        }
                }
                Button("Add Season") {
                    popUpPrompt = "NBA Season"
                    showPopUp = true
                    buttonAction = {
                        if let season = Int(popUpText) {
                            seasons.insert(season)
                        }
                    }
                }
            }
            
            Section("Players") {
                List(players) { player in
                    VStack(alignment: .leading) {
                        Text(player.lastName).bold() + Text(" ") + Text(player.firstName)
                        
                        if let team = player.team {
                            Text("\(team.abbreviation) (\(team.name))")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions {
                        Button("Remove", role: .destructive) {
                            players.removeAll { p in p.id == player.id }
                        }
                    }
                }
                
                Button("Add Player IDs") {
                    showAddPlayer = true
                }
            }
            
            Button("Fetch", systemImage: "arrow.up.arrow.down") {
                fetch()
            }
            .overlay(alignment: .center) {
                if isBusy {
                    ProgressView()
                }
            }
            .disabled(isBusy)
        }
        .scrollBounceBehavior(.basedOnSize)
        .alert("Add Field", isPresented: $showPopUp) {
            TextField(popUpPrompt, text: $popUpText)
            Button("Okay") {
                if popUpText.isEmpty || popUpText.isNumeric == false || popUpText.count != 4 {
                    popUpText = ""
                    return
                }
                
                buttonAction?()
                popUpText = ""
            }
            Button("Cancel", role: .cancel) {
                popUpText = ""
            }
        } message: {
            Text(popUpPrompt)
        }
    }
    
    @ViewBuilder
    func dataView() -> some View {
        VStack {
            NavigationLink("Charts") {
                StatsChartView(playerStats: stats.data)
            }
            .buttonStyle(.bordered)
            
            List(stats.data.sorted()) { stat in
                DisclosureGroup {
                    VStack {
                        Section {
                            if let ast = stat.ast {
                                listTile("Assists:", value: ast.description)
                            }
                            listTile("Blocks:", value: stat.blk.description)
                            listTile("Steals:", value: stat.stl.description)
                        }
                        
                        Text("")
                        
                        Section {
                            listTile("Minutes Played:", value: stat.min.description)
                            listTile("Personal Fouls:", value: stat.pf.description)
                        }
                        
                        Text("")
                        
                        Section("Rebounds") {
                            listTile("Rebounds:", value: stat.reb.description)
                            listTile("Def. Rebounds:", value: stat.dreb.description)
                            listTile("Off. Rebounds:", value: stat.oreb.description)
                        }
                        
                        Text("")
                        
                        Section("Points") {
                            listTile("Scored Points:", value: stat.pts.description)
                            
                            let fieldGoals = "\(stat.fgm) / \(stat.fga) = \(stat.fgPctValue.formatted(.percent))"
                            listTile("Field Goals:", value: fieldGoals)
                            
                            let fieldGoals3 = "\(stat.fg3m) / \(stat.fg3a) = \(stat.fg3PctValue.formatted(.percent))"
                            listTile("3 Pointers:", value: fieldGoals3)
                            
                            let freeThrows = "\(stat.ftm) / \(stat.fta) = \(stat.ftPctValue.formatted(.percent))"
                            listTile("Free Throws:", value: freeThrows)
                        }
                        
                        Text("")
                        
                        Section {
                            listTile("Turnover:", value: stat.turnover.description)
                        }
                    }
                } label: {
                    VStack(alignment: .leading) {
                        Text(stat.player.lastName).bold() + Text(" ") + Text(stat.player.firstName)
                        
                        Text("\(stat.team.abbreviation) (\(stat.team.name))")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.inset)
            
            if !stats.data.isEmpty {
                HStack {
                    if let currentPage = stats.meta.currentPage {
                        if currentPage != 1 {
                            Button {
                                fetch(page: page-1, cachePolicy: .reloadRevalidatingCacheData, append: true)
                            } label: {
                                Label((currentPage - 1).description, systemImage: "arrow.backward")
                            }
                        }
                        
                        Button(currentPage.description) {
                            
                        }
                        .allowsHitTesting(false)
                        .buttonStyle(.borderedProminent)
                    }
                    
                    if let nextPage = stats.meta.nextPage {
                        Button {                            
                            fetch(page: page + 1, cachePolicy: .reloadRevalidatingCacheData, append: true)
                        } label: {
                            Label(nextPage.description, systemImage: "arrow.right")
                        }
                    }
                }
                .disabled(isBusy)
                .labelStyle(.titleOnly)
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
            }
        }
    }
    
    func listTile(_ titleKey: String, value: String) -> some View {
        HStack {
            Text(titleKey)
            
            Spacer()
            
            Text(value)
                .bold()
        }
    }
    
    func fetch(page: Int = 0, cachePolicy: URLRequest.CachePolicy? = nil, append: Bool = false) {
        Task {
            do {
                self.isBusy = true
                let statsList = try await NBAService.shared.fetchPlayerStats(
                    page: page,
                    perPage: 100,
                    seasons: Array(seasons),
                    playerIds: players.map(\Player.id),
                    startDate: nil,
                    endDate: nil,
                    cachePolicy: cachePolicy ?? .reloadRevalidatingCacheData
                )
                
                if append {
                    let combined = self.stats.data + statsList.data
                    self.stats = .init(data: combined, meta: statsList.meta)
                } else {
                    self.stats = statsList
                }
                self.showAddView = false
                self.showError = false
                self.isBusy = false
                self.page = statsList.meta.currentPage ?? 0
            } catch let err {
                if let error = err as? AppError {
                    self.showError = true
                    self.appError = error
                }
                self.isBusy = false
                print(err.localizedDescription)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PlayerStatsSearchView()
            .preferredColorScheme(.dark)
    }
}
