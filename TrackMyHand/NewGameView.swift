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
    @StateObject private var firestoreService = FirestoreService()
    @State private var startGame: Bool = false
    @State private var newGame: Game = Game(isActive: false, id: "", timeElapsed: [0, 0, 0], gameCode: "", totalPot: 0.0, cashOut: 0, date: Date(), players: [], events: [])
    @State private var navigateToGame: Bool = false

    // Game details
    @State private var allPlayers: [Player] = []
    @State private var isQuickAddEnabled: Bool = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                // Section for player details
                Section(header: Text("Players (\(allPlayers.count))")) {
                    if allPlayers.isEmpty && newPlayerUID.isEmpty {
                        Button(action: quickAddFavorites) {
                            Label("Quick Add", systemImage: "star.fill")
                                .font(.headline)
                        }
                        .foregroundStyle(.orange)
                    } else if (!isAllPlayersExisting && !newPlayerUID.isEmpty) {
                        Button(action: {
                            showAlert = true
                        }) {
                            Label("Create User", systemImage: "person.crop.circle.fill.badge.plus")
                                .foregroundStyle(.red)
                        }
                        .alert("Create new user?", isPresented: $showAlert) {
                            Button("Yes") {
                                newPlayerUID = newPlayerUID.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
                                if !(newPlayerUID.isEmpty) {
                                    firestoreService.createUser(id: newPlayerUID) { _ in }
                                    allUsers.append(User(id: newPlayerUID, totalProfit: 0, isFavorite: false, profitData: [0], totalWins: 0, timePlayed: 0, totalBuyIn: 0))
                                    allPlayers.append(Player(id: newPlayerUID, buyIn: 5, cashOut: 0, profit: -5.00))
                                    newPlayerUID = ""
                                    isAllPlayersExisting = true
                                }
                            }
                            
                            Button("Cancel", role: .cancel) {}
                                .foregroundStyle(.red)
                        }
                    } else if (isAllPlayersUnique && !newPlayerUID.isEmpty) || newPlayerUID.isEmpty {
                        Button(action: {
                            if !newPlayerUID.isEmpty {
                                newPlayerUID = newPlayerUID.trimmingCharacters(in: .whitespacesAndNewlines)
                                let newPlayer = Player(id: newPlayerUID, buyIn: 5, cashOut: 0, profit: -5.00)
                                allPlayers.append(newPlayer)
                                newPlayerUID = ""
                            }
                        }) {
                            Label("Add Player", systemImage: "plus.circle")
                        }
                    }


                    if !isAllPlayersUnique {
                        Button(action: {}) {
                            Label("Player Exists", systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.gray)
                        }
                        .disabled(true)
                    }

                    TextField("Player Name", text: $newPlayerUID)
                        .disableAutocorrection(true)
                        .autocapitalization(.allCharacters)
                        .onChange(of: newPlayerUID) { _, newValue in
                            validatePlayerInput(newValue)
                        }

                    ForEach(allPlayers.reversed()) { player in
                        Text(player.id)
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                            .bold()
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    removePlayer(player)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }

                HStack {
                    Text("Buy in ($)")
                        .foregroundStyle(.white).opacity(0.7)
                    Divider()
                        .padding(.horizontal, 5)
                    Text("5")
                        .bold()
                    Spacer()
                    Text("Dollars")
                        .foregroundStyle(.white).opacity(0.7)
                }

            // Save button
                Button("Create Game", action: createGame)
                    .disabled(allPlayers.count < 2)
            }
            .navigationTitle("Create Game")
            .onAppear(perform: fetchUsers)
            .navigationDestination(isPresented: $navigateToGame) {
                OngoingGameView(game: newGame, allUsers: allUsers)
            }
        }
    }

    // MARK: - Helper Functions
    private func quickAddFavorites() {
        let favorites = ["LAKSH", "ATHARV", "SAHAJ", "USMAAN", "AREEB", "SAIF", "ANIRUDH", "LAKSHYA"]
        allPlayers = favorites.map { Player(id: $0, buyIn: 5, cashOut: 0, profit: -5.00) }
    }

    private func createNewUser() {
        newPlayerUID = newPlayerUID.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newPlayerUID.isEmpty else { return }

        firestoreService.createUser(id: newPlayerUID) { _ in }
        allUsers.append(User(id: newPlayerUID, totalProfit: 0, isFavorite: false, profitData: [0], totalWins: 0, timePlayed: 0, totalBuyIn: 0))
        allPlayers.append(Player(id: newPlayerUID, buyIn: 5, cashOut: 0, profit: -5.00))
        newPlayerUID = ""
        isAllPlayersExisting = true
    }

    private func addPlayer() {
        newPlayerUID = newPlayerUID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newPlayerUID.isEmpty else { return }

        let newPlayer = Player(id: newPlayerUID, buyIn: 5, cashOut: 0, profit: -5.00)
        allPlayers.append(newPlayer)
        newPlayerUID = ""
    }

    private func validatePlayerInput(_ input: String) {
        newPlayerUID = input.uppercased()
        isAllPlayersUnique = !allPlayers.contains { $0.id == newPlayerUID.trimmingCharacters(in: .whitespacesAndNewlines) }
        isAllPlayersExisting = allUsers.contains { $0.id == newPlayerUID.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    private func removePlayer(_ player: Player) {
        allPlayers.removeAll { $0.id == player.id }
    }

    private func createGame() {
        let uid = UUID().uuidString
        let totalPot = Double(allPlayers.count) * 5.0
        let gameCode = String(uid.prefix(3) + uid.suffix(3))

        newGame = Game(
            isActive: true,
            id: uid,
            timeElapsed: [0, 0, 0],
            gameCode: gameCode,
            totalPot: totalPot,
            cashOut: 0,
            date: Date(),
            players: allPlayers,
            events: []
        )

        firestoreService.createGame(game: newGame) { error in
            if error == nil {
                navigateToGame = true
            } else {
                print("Error saving game: \(error!.localizedDescription)")
            }
        }
    }

    private func fetchUsers() {
        firestoreService.fetchUsers { users in
            allUsers = users
        }
    }
}


#Preview {
    NewGameView()
}



