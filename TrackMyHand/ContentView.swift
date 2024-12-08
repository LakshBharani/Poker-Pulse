//
//  ContentView.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 19/11/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.games) { game in
                NavigationLink(destination: GameDetailView(game: game)) {
                    VStack(alignment: .leading) {
                        Text("Game ID: \(game.game_id)").font(.headline)
                        Text("Date: \(game.date)").font(.subheadline)
                        Text("Location: \(game.location)").font(.subheadline)
                    }
                }
            }
            .navigationTitle("All Game")
            .navigationBarItems(trailing: HStack {
                Button {
                    
                } label: {
                    Text("Create Game")
                }
            })
            .onAppear {
                viewModel.fetchGames()
            }
        }
    }
}

struct GameDetailView: View {
    let game: Game

    var body: some View {
        VStack {
            Text("Game Details")
                .font(.largeTitle)
            Text("Location: \(game.location)")
            Text("Date: \(game.date)")
            List(game.players) { player in
                VStack(alignment: .leading) {
                    Text("Player: \(player.name)").font(.headline)
                    Text("Net Cash: \(player.net_cash)")
                    Text("Settled: \(player.settled ? "Yes" : "No")")
                }
            }
        }
        .padding()
    }
}


#Preview {
    ContentView()
}
