//
//  AllGames.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 15/02/25.
//

import SwiftUI

struct AllGames: View {
    @StateObject private var firestoreService = FirestoreService()
    @State private var searchText: String = ""
    @State private var games: [Game] = []
    @State private var users: [User] = []
    
    var visibleGames: [Game] {
            if searchText.isEmpty {
                return games
            } else {
                return games.filter { $0.id.localizedCaseInsensitiveContains(searchText) }
            }
        }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.green.opacity(0.25), .black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if games.isEmpty {
                        LoadingView(subTitle: "Fetching games...")
                    }
                    else {
                        List {
                            ForEach(visibleGames) { game in
                                HStack {
                                    NavigationLink(destination: OngoingGameView(game: game, allUsers: users)) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(game.gameCode)")
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.orange)
                                            Text("\(game.date.formatted(date: .long, time: .shortened))")
                                                .foregroundColor(.white).opacity(0.7)
                                                .bold()
                                                .font(.system(size: 14))
                                            Text("Players : \(game.players.count - 1)")
                                                .foregroundColor(.white).opacity(0.7)
                                                .bold()
                                                .font(.system(size: 14))
                                                .font(.system(size: 14))
                                            Text("Total Buy-In : \(game.totalPot, specifier: "%.2f")")
                                                .foregroundColor(.white).opacity(0.7)
                                                .bold()
                                                .font(.system(size: 14))
                                        }
                                    }
                                }
                            }
                        }
                        .searchable(text: $searchText)
                        .scrollContentBackground(.hidden)
                    }
                    PlacableAdBanner(adIdentifier: "banner0")
                }
            }
        }
        .navigationTitle("All Games")
        .onAppear() {
            firestoreService.fetchGames(limit: 100) { games in
                self.games = games
            }
            firestoreService.fetchUsers() { users in
                self.users = users
            }
        }
    }
}

#Preview {
    AllGames()
}
