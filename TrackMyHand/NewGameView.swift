//
//  NewGameView.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 14/12/24.
//

import SwiftUI

struct NewGameView: View {
    struct AuthData {
        var pin: String = ""
        var isValid: Bool = false
    }
    
    @State private var showTextField = false
    @State private var newPlayerUID: String = ""
    @State var buyInAmount: String = "0"
    @State private var isAllPlayersUnique: Bool = true
    @State private var isAllPlayersExisting: Bool = true
    @State private var showAlert = false
    @State private var allUsers: [User] = []
    @State private var playerPins: [String: AuthData] = [:]
    @StateObject private var firestoreService = FirestoreService()
    @State private var startGame: Bool = false
    @State private var newGame: Game = Game(isActive: false, buyIn: 0, isGameEnded: false, id: "", timeElapsed: [0, 0, 0], gameCode: "", totalPot: 0.0, cashOut: 0, date: Date(), players: [], events: [])
    @State private var navigateToGame: Bool = false
    @State private var playerPin: String = ""
    @State private var isOKDisabled: Bool = true

    // Game details
    @State private var allPlayers: [Player] = []
    @State private var isQuickAddEnabled: Bool = false
    @State private var errorMessage = ""
    @State private var favorites: [String] = []

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.orange.opacity(0.2), .black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
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
                            .alert("Create Player", isPresented: $showAlert) {
                                VStack {
                                    TextField("Enter a 3-10 digit PIN", text: $playerPin)
                                        .keyboardType(.numberPad)
                                        .onChange(of: playerPin) { oldValue, newValue in
                                            if newValue.count > 10 {
                                                playerPin = String(newValue.prefix(10))
                                            } else if newValue.count < 3 {
                                                isOKDisabled = true
                                            } else {
                                                playerPin = newValue.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
                                                isOKDisabled = false
                                            }
                                        }
                                }
                        
                                Button("OK") {
                                    firestoreService.createUser(id: newPlayerUID, pin: playerPin) { _ in }
                                    allUsers.append(User(id: newPlayerUID, pin: playerPin, totalProfit: 0, isFavorite: false, profitData: [0], totalWins: 0, timePlayed: 0, totalBuyIn: 0))
                                    allPlayers.append(Player(id: newPlayerUID, buyIn: Double(buyInAmount)!, cashOut: 0, profit: -1 * Double(buyInAmount)!))
                                    newPlayerUID = ""
                                    playerPin = ""
                                }
                                .disabled(isOKDisabled)
                                
                                Button("Cancel", role: .cancel) {
                                    newPlayerUID = ""
                                }
                            } message : {
                                Text("Player must set a 3-10 digit pin.\nIt will be used as their login credentials.")
                            }
                            
                            
                        } else if (isAllPlayersUnique && !newPlayerUID.isEmpty) || newPlayerUID.isEmpty {
                            Button(action: {
                                if !newPlayerUID.isEmpty {
                                    newPlayerUID = newPlayerUID.trimmingCharacters(in: .whitespacesAndNewlines)
                                    let newPlayer = Player(id: newPlayerUID, buyIn: Double(buyInAmount)!, cashOut: 0, profit: -1 * Double(buyInAmount)!)
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
                            HStack {
                                Text(player.id)
                                    .font(.subheadline)
                                    .foregroundStyle(.orange)
                                    .bold()
                                
                                Spacer()
                                
                                SecureField("PIN", text: Binding(
                                    get: { playerPins[player.id]?.pin ?? "" },
                                    set: { newValue in
                                        updatePlayerPin(playerID: player.id, newPin: newValue)
                                    }
                                ))
                                .keyboardType(.numberPad)
                                .font(.subheadline)
                                .foregroundStyle(.orange)
                                .bold()
                                .frame(width: 100)
                                
                                // Show validation result (checkmark or X based on isValid)
                                if let isValid = playerPins[player.id]?.isValid {
                                    Image(systemName: isValid ? "checkmark.circle" : "xmark.circle")
                                        .foregroundColor(isValid ? .green : .red)
                                } else {
                                    Image(systemName: "xmark.circle")
                                        .foregroundColor(.red)
                                }
                            }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        removePlayer(player)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        toggleFavorite(userID: player.id)
                                    } label: {
                                        Label(
                                            isInFavorites(userID: player.id) ? "Unfavorite" : "Favorite",
                                            systemImage: isInFavorites(userID: player.id) ? "star.fill" : "star"
                                        )
                                    }
                                    .tint(isInFavorites(userID: player.id) ? .orange : .blue)
                                }
                        }
                    }

                    HStack {
                        Text("Buy in ($)")
                            .foregroundStyle(.white).opacity(0.7)
                        Divider()
                            .padding(.horizontal, 5)
                        TextField("amount", text: $buyInAmount)
                            .keyboardType(.decimalPad)
                        Spacer()
                        Text("Dollars")
                            .foregroundStyle(.white).opacity(0.7)
                    }

                // Save button
                    Button("Create Game", action: authenticateAllPlayers)
                        .disabled(allPlayers.count < 2 || buyInAmount.isEmpty)
                }
                .navigationTitle("Create Game")
                .onAppear(perform: fetchUsers)
                .navigationDestination(isPresented: $navigateToGame) {
                    OngoingGameView(game: newGame, allUsers: allUsers)
                        .transition(.slide)
                }
            }
            PlacableAdBanner(adIdentifier: "banner0")
        }
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Helper Functions
    private func quickAddFavorites() {
        let favorites = allUsers.filter { $0.isFavorite }.map { $0.id }
        allPlayers = favorites.map { Player(id: $0, buyIn: Double(buyInAmount)!, cashOut: 0, profit: -1 * Double(buyInAmount)!) }
    }

    private func createNewUser() {
        newPlayerUID = newPlayerUID.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newPlayerUID.isEmpty else { return }

        firestoreService.createUser(id: newPlayerUID) { _ in }
        allUsers.append(User(id: newPlayerUID, totalProfit: 0, isFavorite: false, profitData: [0], totalWins: 0, timePlayed: 0, totalBuyIn: 0))
        allPlayers.append(Player(id: newPlayerUID, buyIn: Double(buyInAmount)!, cashOut: 0, profit: -1 * Double(buyInAmount)!))
        newPlayerUID = ""
        isAllPlayersExisting = true
    }

    private func addPlayer() {
        newPlayerUID = newPlayerUID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newPlayerUID.isEmpty else { return }

        let newPlayer = Player(id: newPlayerUID, buyIn: Double(buyInAmount)!, cashOut: 0, profit: -1 * Double(buyInAmount)!)
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
    
    private func initializeFavorites() {
        favorites = allUsers.filter { $0.isFavorite }.map { $0.id }
    }

    private func toggleFavorite(userID: String) {
        if let index = allUsers.firstIndex(where: { $0.id == userID }) {
            // Toggle the isFavorite flag
            allUsers[index].isFavorite.toggle()
            favorites = allUsers.filter { $0.isFavorite }.map { $0.id }
            // Update Firestore to reflect the change
            firestoreService.toggleFavorite(userID: userID) { error in
                if (error != nil) {
                    initializeFavorites()
                }
            }
        }
    }


    private func isInFavorites(userID: String) -> Bool {
        favorites.contains(userID)
    }

    private func createGame() {
        let uid = UUID().uuidString
        let totalPot = Double(allPlayers.count) * Double(buyInAmount)!
        let gameCode = String(uid.prefix(3) + uid.suffix(3))
        for index in allPlayers.indices {
            allPlayers[index].buyIn = Double(buyInAmount)!
            allPlayers[index].profit = -1 * Double(buyInAmount)!
        }

        newGame = Game(
            isActive: true,
            // TODO: fix buy in
            buyIn: Double(buyInAmount)!,
            isGameEnded: false,
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
            favorites = allUsers.filter { $0.isFavorite }.map { $0.id }
        }
    }

    
    private func updatePlayerPin(playerID: String, newPin: String) {
        let isValid = playerPins[playerID]?.isValid ?? false
        playerPins[playerID] = AuthData(pin: newPin, isValid: isValid)
    }
    
    private func authenticateAllPlayers() {
        var isAllValid = true
        for user in allPlayers {
            let playerID = allUsers.first(where: { $0.id == user.id })?.pin ?? ""
            let isValid = authenticate(enteredPin: playerPins[user.id]?.pin ?? "", actualPin: playerID)
            playerPins[user.id]?.isValid = isValid
            isAllValid = isAllValid && isValid
        }
        if isAllValid {
            createGame()
        }
    }

    private func authenticate(enteredPin: String, actualPin: String) -> Bool {
        return enteredPin == actualPin
    }
}


#Preview {
    NewGameView()
}



