//
//  PlayersScreen.swift
//  BallNoLie
//
//  Created by Sharan Thakur on 24/01/24.
//

import SwiftUI

struct PlayersScreen: View {
    @State private var progressState: ProgressState<PlayerList> = .error(AppError.serviceOffline)
    @State private var page = 0
    @State private var searchText = ""
    
    var onPlayerSelect: ((Player) -> Void)? = nil
    
    var body: some View {
        VStack {
            switch progressState {
            case .loading:
                ProgressView()
            case .error(let error):
                ContentUnavailableView(error.localizedDescription, systemImage: "network")
                    .symbolVariant(.slash)
                    .symbolEffect(
                        .variableColor.iterative.hideInactiveLayers.reversing,
                        options: .speed(0.1)
                    )
            case .data(let value):
                dataView(value)
            }
        }
        .navigationTitle("Players ⛹🏼‍♂️")
        .navigationBarTitleDisplayMode(.automatic)
        .onAppear {
            fetch(page: page, search: nil)
        }
    }
    
    @ViewBuilder
    func dataView(_ data: PlayerList) -> some View {
        List(data.data) { player in
            VStack(alignment: .leading) {
                HStack {
                    Text("\(player.firstName) \(player.lastName)")
                    
                    Spacer()
                    
                    Text("(\(player.position))")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    if let team = player.team {
                        Text(team.name)
                            .foregroundStyle(.secondary)
                    }
                    
                    if let heightFeet = player.heightFeet, let heightInches = player.heightInches, let weight = player.weightPounds {
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("H: \(heightFeet.formatted(.number))' \(heightInches.formatted())")
                                .foregroundStyle(.secondary)
                            
                            Text("W: \(weight.formatted(.number))")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .onTapGesture {
                onPlayerSelect?(player)
            }
        }
        .searchable(text: $searchText)
        .listStyle(.inset)
        .refreshable {
            if searchText.isEmpty {
                fetch(page: page, search: nil)
            } else {
                fetch(page: page, search: searchText)
            }
        }
        .onSubmit(of: .search) {
            if searchText.isEmpty {
                fetch(page: page, search: nil)
            } else {
                fetch(page: page, search: searchText)
            }
        }
        
        HStack {
            if let currentPage = data.meta.currentPage {
                if currentPage != 1 {
                    Button {
                        withAnimation {
                            page -= 1
                        }
                        fetch(page: page, search: nil)
                    } label: {
                        Label((currentPage - 1).description, systemImage: "arrow.backward")
                    }
                }
                
                Button(currentPage.description) {
                    
                }
                .allowsHitTesting(false)
                .buttonStyle(.borderedProminent)
            }
            
            if let nextPage = data.meta.nextPage {
                Button {
                    withAnimation {
                        page += 1
                    }
                    fetch(page: page, search: nil)
                } label: {
                    Label(nextPage.description, systemImage: "arrow.right")
                }
            }
        }
        .labelStyle(.titleOnly)
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
    }
    
    func fetch(page: Int, perPage: Int = 40, search: String?) {
        self.progressState = .loading
        
        Task {
            do {
                let data = try await NBAService.shared.fetchAllPlayers(searchPrompt: searchText, page: page, perPage: perPage, cachePolicy: .reloadRevalidatingCacheData)
                let sortedList = data.data.sorted { $0.firstName < $1.firstName }
                progressState = .data(PlayerList(data: sortedList, meta: data.meta))
                self.page = data.meta.currentPage ?? self.page
            } catch {
                progressState = .error(error)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PlayersScreen {
            print($0.firstName)
        }
    }
}
