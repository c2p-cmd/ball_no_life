//
//  ContentView.swift
//  BallNoLie
//
//  Created by Sharan Thakur on 24/01/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        List {
            Section("Choose your view") {
                NavigationLink {
                    TeamsScreen()
                } label: {
                    Text("Teams Screen")
                }

                NavigationLink {
                    PlayersScreen()
                } label: {
                    Text("Players Screen")
                }
                
                NavigationLink("Players Stats", destination: PlayerStatsSearchView.init)
            }
            .buttonStyle(.plain)
        }
        .navigationTitle("Screens")
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
