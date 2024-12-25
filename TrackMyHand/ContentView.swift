//
//  ContentView.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 19/11/24.
//

import SwiftUI
import CoreData


struct ContentView: View {
    @StateObject private var firestoreService = FirestoreService()
    @Environment(\.colorScheme) var colorScheme
    @State private var users: [User] = []
    @State private var games: [Game] = []
    @State private var gamesFetched = 7
    @State private var totalUsers = 0
    @State private var totalGames = 0
    
    
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Leaderboard (\(totalUsers))")) {
                    ForEach(users) { user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.id)
                                    .font(.headline)
                                    .foregroundStyle(colorScheme == .dark ? .orange : .black)
                                Text("Games Played: \(user.profitData.count - 1)")
                                    .padding(.bottom, 2)
                                Text("+\(user.totalProfit, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundStyle(.black)
                                    .frame(width: 60, alignment: .trailing)
                                    .padding(EdgeInsets.init(top: 1, leading: 5, bottom: 1, trailing: 5))
                                    .background(content: {
                                        RoundedRectangle(cornerRadius: CGFloat(5))
                                            .foregroundStyle(.green)
                                    })
                            }
                            
                            Spacer()
                            
                            Image(systemName: "medal.fill")
                                .font(.title)
                                .foregroundStyle(getBadgeColor(index: users.firstIndex(where: { $0.id == user.id })!))
                        }
                        .background(
                            NavigationLink(destination: UserDetails(user: user)) {}
                                .opacity(0)
                        )
                    }
                    NavigationLink(destination: AllUsers()) {
                        Button("Show More") {}
                    }
                    .disabled(users.isEmpty)
                }
                
                Section(header: Text("Games (\(totalGames))")) {
                    NavigationLink(destination: NewGameView()) {
                        Button("New Game") {}
                    }
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
                reloadData()
            }
            .navigationTitle("Poker Tracker")
        }
        .onAppear {
            reloadData()
        }
    }
    
    func reloadData() {
        firestoreService.fetchLeaderboard { users in
            self.users = users
        }
        firestoreService.fetchGames(limit: gamesFetched) { games in
            self.games = games
        }
        firestoreService.fetchTotalUserCount() { count in
            self.totalUsers = count ?? totalUsers
        }
        firestoreService.fetchTotalGameCount() { count in
            self.totalGames = count ?? totalGames
        }
    }
    
    func getBadgeColor(index: Int) -> Color {
        if index == 0 {
            return Color.orange
        } else if index == 1 {
            return Color.gray.mix(with: Color.white, by: 0.6)
        } else if index == 2 {
            return Color.brown.mix(with: Color.red, by: 0.35)
        }
        else {
            return Color.red
        }
    }
}



#Preview {
    ContentView()
}

