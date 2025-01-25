//
//  ContentView.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 19/11/24.
//

import SwiftUI
import CoreData
import GoogleMobileAds


struct HomeView: View {
    @StateObject private var firestoreService = FirestoreService()
    @Environment(\.colorScheme) var colorScheme
    @State private var users: [User] = []
    @State private var games: [Game] = []
    @State private var gamesFetched = 5
    @State private var totalUsers = 0
    @State private var totalGames = 0
    @State private var signOutAlert: Bool = false
    @State private var isSignedOut: Bool = false
    
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.green.opacity(0.25), .black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                List {
                    Section(header: Text("Leaderboard (\(totalUsers))")) {
                        ForEach(users) { user in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(user.id)
                                        .font(.headline)
                                        .foregroundStyle(colorScheme == .dark ? .orange : .black)
                                    Text("Games Played : \(user.profitData.count - 1)")
                                        .foregroundColor(.white).opacity(0.7)
                                        .bold()
                                        .font(.system(size: 14))
                                    Text("\(user.totalProfit >= 0 ? "+" : "-") \(abs(user.totalProfit), specifier: "%.2f")")
                                        .font(.system(size: 14))
                                        .bold()
                                        .foregroundStyle(user.totalProfit >= 0 ? .green : .red)
                                        .padding(EdgeInsets.init(top: 1, leading: 5, bottom: 1, trailing: 5))
                                        .background(content: {
                                            RoundedRectangle(cornerRadius: CGFloat(5))
                                                .foregroundStyle(user.totalProfit >= 0 ? .green.opacity(0.2) : .red.opacity(0.2))
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
                            .background(
                                NavigationLink(destination: OngoingGameView(game: game, allUsers: users)) {}
                                    .opacity(0)
                            )
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .refreshable {
                reloadData()
            }
            .navigationTitle("Poker Tracker")
//            .toolbar {
//                ToolbarItem {
//                    Menu {
//                        Button("Show Login QR", systemImage: "qrcode") {}
//                            .disabled(true)
//                        
//                        Text("Groups coming soon...")
//                        
//                        //                        NavigationLink(destination: JoinGroupView()) {
//                        //                            Button("Switch Group", systemImage: "arrow.left.arrow.right") {}
//                        //                        }
//                        //                        .disabled(true)
//                        //
//                        //                        Button("Exit Group", role: .destructive) {}
//                        //                            .disabled(true)
//                        
//                        Button("Sign Out", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) {
//                            signOutAlert = true
//                        }
//                    } label: {
//                        Label("Menu", systemImage: "ellipsis.circle")
//                    }
//                    .alert("Sign Out", isPresented: $signOutAlert) {
//                        Button("Cancel", role: .cancel) { }
//                        Button("OK") {
//                            isSignedOut = true
//                        }
//                    } message: {
//                        Text("Are you sure you want to sign out?")
//                    }
//                    .navigationDestination(isPresented: $isSignedOut) {
//                        AuthView()
//                            .transition(.slide)
//                    }
//                }
//            }
            PlacableAdBanner(adIdentifier: "banner0")
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
    HomeView()
}

