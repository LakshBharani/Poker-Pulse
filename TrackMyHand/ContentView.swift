//
//  ContentView.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 19/11/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var service = FirestoreService()
    @Environment(\.colorScheme) var colorScheme
    @State private var showingNewGame = false
    @State private var showingAllUsers = false
    @State private var users: [User] = []
    @State private var games: [Game] = []
    @State private var gamesFetched = 7
    
    var body: some View {
        NavigationStack {
            
            List {
                Section(header: Text("Leaderboard (\(users.count))")) {
                    
                    ForEach(users) { user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.id)
                                    .font(.headline)
                                    .foregroundStyle(colorScheme == .dark ? .orange : .black)
                                Text("Games Played: \(user.gamesPlayed)")
                                Text("Total Profit: \(user.totalProfit, specifier: "%.2f")")
                            }
                            
                            Spacer()
                            
                            Image(systemName: "medal.fill")
                                .font(.title)
                                .foregroundStyle(.orange)
                        }
                    }
                    NavigationLink(destination: AllUsers()) {
                        Button("Show More") {
                            showingAllUsers = true
                        }
                    }
                    .disabled(users.isEmpty)
                }
                
                Section(header: Text("Games (\(games.count))")) {
                    Button("New Game") { showingNewGame = true }
                    ForEach(games) { game in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(game.date.formatted(date: .long, time: .shortened))")
                                    .fontWeight(.semibold)
                                Text("Players : \(game.players.count)")
                                    .font(.callout)
                                let totalPot = game.players.reduce(0) { $0 + $1.buyIn }
                                Text("Total Pot: \(totalPot, specifier: "%.2f")")
                                    .font(.callout)
                            }
                        }
                    }
                }
            }
            .refreshable {
                service.fetchLeaderboard { users in
                    self.users = users
                    print(users)
                }
                service.fetchGames(limit: gamesFetched) { games in
                    self.games = games
                }
            }
            .navigationTitle("Poker Tracker")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: CreateNewProfile()) {
                        Image(systemName: "person.fill.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewGame) {
                NewGameView()
            }
            
        }
        .onAppear {
            service.fetchLeaderboard { users in
                self.users = users
            }
            service.fetchGames(limit: gamesFetched) { games in
                self.games = games
            }
        }
    }
}



#Preview {
    ContentView()
}

