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
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetch(page: page, search: nil)
        }
    }
    
    @ViewBuilder
    func dataView(_ data: PlayerList) -> some View {
        List(data.data) { player in
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(player.firstName) \(player.lastName)")
                        
                        Spacer()
                        
                        Text("(\(player.position))")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text(player.team.name)
                            .foregroundStyle(.secondary)
                        
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
            }
        }
        .searchable(text: $searchText)
        .listStyle(.grouped)
        .refreshable {
            if searchText.isEmpty == false {
                fetch(page: page, search: searchText)
            } else {
                fetch(page: page, search: nil)
            }
        }
        .onSubmit(of: .search) {
            if searchText.isEmpty == false {
                fetch(page: page, search: searchText)
            } else {
                fetch(page: page, search: nil)
            }
        }
        
        HStack {
            if data.meta.currentPage != 1 {
                Button {
                    withAnimation {
                        page -= 1
                    }
                    fetch(page: page, search: nil)
                } label: {
                    Label((data.meta.currentPage - 1).description, systemImage: "arrow.backward")
                }
            }
            
            Button(data.meta.currentPage.description) {
                
            }
            .allowsHitTesting(false)
            .buttonStyle(.borderedProminent)
            
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
                self.page = data.meta.currentPage
            } catch {
                progressState = .error(error)
            }
        }
    }
}

#Preview {
    PlayersScreen()
}
