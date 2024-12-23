//
//  NewGameView.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 14/12/24.
//

import SwiftUI

struct NewGameView: View {
    @State private var showTextField = false
    @State private var newPlayerUID: String = ""
    @State private var buyInAmount: String = "5"
    @State private var isAllPlayersUnique: Bool = true
    @State private var isAllPlayersExisting: Bool = true
    @State private var showAlert = false
    @State private var allUsers: [User] = []
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var firestoreService = FirestoreService()
    @State private var startGame: Bool = false
    @State private var newGame: Game = Game(isActive: false, id: "", gameCode: "", totalPot: 0.0, date: Date(), players: [], transactions: [])
    
    // Game details
    @State private var allPlayers: [Player] = []
    @State private var isQuickAddEnabled: Bool = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                // Section for player details
                Section(header: Text("Players")) {
                    
                    if (allPlayers.isEmpty && newPlayerUID.isEmpty) {
                        Button(action: {
                            // TODO: write function to save favorites in DB and fetch
                            let favorites = ["LAKSH", "ATHARV", "SAHAJ", "USMAAN", "AREEB", "SAIF", "ANIRUDH", "LAKSHYA"]
                            for user in favorites {
                                let newPlayer = Player(id: user, buyIn: 5, cashOut: 0, profit: 0)
                                allPlayers.append(newPlayer)
                            }
                        }) {
                            Label("Quick Add", systemImage: "star.fill")
                                .font(.headline)
                        }
                        .foregroundStyle(.orange)
                    }
                    
                    else if (!isAllPlayersExisting && !newPlayerUID.isEmpty) {
                        Button(action: {
                            showAlert = true
                        }) {
                            Label("Create User", systemImage: "person.crop.circle.fill.badge.plus")
                                .foregroundStyle(.red)
                        }
                        .alert("Create new user?", isPresented: $showAlert) {
                            Button("Yes") {
                                newPlayerUID = newPlayerUID.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
                                if (!(newPlayerUID == "")) {
                                    firestoreService.createUser(id: newPlayerUID) {_ in}
                                    allUsers.append(User(id: newPlayerUID, totalProfit: 0, isFavorite: false, profitData: [0], totalWins: 0, timePlayed: 0, totalBuyIn: 0))
                                    allPlayers.append(Player(id: newPlayerUID, buyIn: 5, cashOut: 0, profit: 0))
                                    newPlayerUID = ""
                                    isAllPlayersExisting = true
                                }
                            }
                            
                            Button("Cancel", role: .cancel) {
                                
                            }
                            .foregroundStyle(.red)
                        }
                    }
                    
                    else {
                        Button(action: {
                            if (!newPlayerUID.isEmpty) {
                                newPlayerUID = newPlayerUID.trimmingCharacters(in: .whitespacesAndNewlines)
                                let newPlayer = Player(id: newPlayerUID, buyIn: 5, cashOut: 0, profit: 0)
                                allPlayers.append(newPlayer)
                                newPlayerUID = ""
                            }
                        }) {
                            Label("Add Player", systemImage: "plus.circle")
                        }
                    }
                    
                    if (!isAllPlayersUnique) {
                        Button(action: {
                        }) {
                            Label("Player Exists", systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.gray)
                        }
                        .disabled(true)
                    }
                    
                    
                    TextField("Player Name", text: $newPlayerUID)
                        .disableAutocorrection(true)
                        .autocapitalization(.allCharacters)
                        .onChange(of: newPlayerUID) { oldValue, newValue in
                            if !newValue.isEmpty {
                                if allPlayers.contains(where: { $0.id == newPlayerUID.trimmingCharacters(in: .whitespacesAndNewlines) }) {
                                    isAllPlayersUnique = false
                                } else {
                                    isAllPlayersUnique = true
                                }
                                
                                if allUsers.contains(where: { $0.id == newPlayerUID.trimmingCharacters(in: .whitespacesAndNewlines)}) {
                                    isAllPlayersExisting = true
                                } else {
                                    isAllPlayersExisting = false
                                }
                            }
                        }

                    ForEach(allPlayers.reversed()) { player in
                        VStack {
                            Text("\(player.id)")
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        if let index = allPlayers.firstIndex(where: { $0.id == player.id }) {
                                            allPlayers.remove(at: index)
                                        }
                                        
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                
                Section {
                    HStack {
                        Text("Buy in ($)")
                            .font(.headline)
                        Text("5")
                        Spacer()
                        Text("Dollars")
                    }
                    
                }
                
                // Save button
                Section {
                    Button("Create Game") {
                    let uid = UUID().uuidString
                    let totalPot = Double(allPlayers.count) * 5.0
                    let gameCode = String(uid.prefix(3) + uid.suffix(3))
                        
                    newGame = Game(
                        isActive: true,
                        id: uid,
                        gameCode: gameCode,
                        totalPot: totalPot,
                        date: Date(),
                        players: allPlayers,
                        transactions: []
                    )
                    firestoreService.createGame(game: newGame) { error in
                        if let error = error {
                            print("Error saving game: \(error.localizedDescription)")
                        }
                    }
                    }
                    .disabled(allPlayers.count < 2)
                    .background(
                        NavigationLink(destination: OngoingGameView(game: newGame)) {}
                            .opacity(0)
                            .disabled(allPlayers.count < 2)
                    )
                }
            }
            .navigationTitle("Create Game")
        }
        .onAppear() {
            firestoreService.fetchUsers { users in
                self.allUsers = users
            }
        }
    }
}


#Preview {
    NewGameView()
}



