//
//  TeamsScreen.swift
//  BallNoLie
//
//  Created by Sharan Thakur on 24/01/24.
//

import SwiftUI

struct TeamsScreen: View {
    @State private var progressState: ProgressState<[Team]> = .error(AppError.serviceOffline)
    
    var body: some View {
        VStack {
            switch progressState {
            case .loading:
                loadingView()
            case .error(let error):
                errorView(error)
            case .data(let value):
                dataView(value)
                    .listStyle(.grouped)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .scrollContentBackground(.hidden)
        .onAppear(perform: fetch)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("All Teams 🏀")
    }
    
    func errorView(_ error: Error) -> some View {
        ContentUnavailableView(error.localizedDescription, systemImage: "network")
            .symbolVariant(.slash)
            .symbolEffect(.variableColor.iterative.hideInactiveLayers.reversing, options: .speed(0.1))
    }
    
    func dataView(_ teams: [Team]) -> some View {
        List(teams, id: \.id) { team in
            DisclosureGroup {
                Text("City: ") + Text(team.city).bold()
                Text("Conference: ") + Text(team.conference).bold()
                Text("Division: ") + Text(team.division).bold()
            } label: {
                VStack(alignment: .leading) {
                    Text("\(team.abbreviation) - \(team.name)")
                    Text(team.fullName)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    func loadingView() -> some View {
        ProgressView()
    }
    
    func mapBy(keyPath: KeyPath<Team, String>, teams: [Team]) -> [String: [Team]] {
        var result: [String: [Team]] = [:]
        
        teams.forEach {
            let key = $0[keyPath: keyPath]
            
            if result.keys.contains(key) {
                result[key]?.append($0)
            } else {
                result[key] = [$0]
            }
        }
        
        return result
    }
    
    func fetch() {
        self.progressState = .loading
        
        Task {
            do {
                let data = try await NBAService.shared.fetchAllTeams(cachePolicy: .reloadRevalidatingCacheData)
                progressState = .data(data)
            } catch {
                progressState = .error(error)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TeamsScreen()
            .preferredColorScheme(.light)
    }
}
