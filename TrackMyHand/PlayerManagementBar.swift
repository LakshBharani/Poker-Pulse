//
//  PlayerManagementBar.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 05/01/25.
//

import SwiftUI

struct PlayerManagementBar: View {
    @StateObject private var firestoreService = FirestoreService()
    @State private var playerId: String = ""
    @State private var playerPin: String = ""
    @State private var isVerifiedUser: Bool = false
    @State private var isAddingNewPlayer: Bool = false
    @State private var isOKDisabled: Bool = true
    @State private var showNewPlayerAlert: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var allUsers: [User] = []
    @Binding var game: Game
    
    
    func logEvent(newEvent: Transaction) {
        if let playerIndex = game.players.firstIndex(where: { $0.id == newEvent.to }) {
            game.players[playerIndex].profit -= Double(newEvent.amount)!
            if (newEvent.description != "player joined") {
                game.players[playerIndex].buyIn += Double(newEvent.amount)!
            }
        }
        
        game.totalPot += Double(newEvent.amount)!
        
        if let playerIndex = game.players.firstIndex(where: { $0.id == newEvent.from }) {
            game.players[playerIndex].profit += Double(newEvent.amount)!
        }
        
        game.events.append(newEvent)
        firestoreService.updateGameOnEvent(game: game) { result in
            if result != nil {
                print("Game Updated")
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Add Player")
                .font(.title3).bold()
                .foregroundStyle(.orange)
                .padding(.bottom, 5)
            Text("Enter Player ID & PIN of an existing player to add them to the game. To create a new player, create a unique ID & PIN and add them to the game.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 10)
            
            HStack {
                VStack {
                    TextField("Player ID", text: $playerId)
                        .font(.subheadline)
                        .foregroundStyle(isVerifiedUser ? .gray : .primary)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.bottom, 2)
                        .onChange(of: playerId) { oldValue, newValue in
                            playerId = newValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                            isVerifiedUser = false
                        }
                    
                    if isVerifiedUser {
                        SecureField("PIN", text: $playerPin)
                            .keyboardType(.numberPad)
                            .font(.subheadline)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onChange(of: playerPin) { oldValue, newValue in
                                playerPin = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                    }
                }
                
                if isVerifiedUser {
                    let isPwdMatching = allUsers.contains(where: { $0.id == playerId && $0.pin == playerPin })
                    
                    Button {
                        if isPwdMatching {
                            let newPlayer = Player(id: playerId, buyIn: 5.00, cashOut: 0.00, profit: 0.00)
                            let transaction = Transaction(id: game.events.count, description: "player joined", from: "BANK", to: playerId, amount: String(format: "%.2f", newPlayer.buyIn))
                            game.players.append(newPlayer)
                            logEvent(newEvent: transaction)
                            playerId = ""
                            playerPin = ""
                            errorMessage = ""
                            showErrorAlert = false
                        } else {
                            errorMessage = "Invalid Player Pin"
                            showErrorAlert = true
                        }
                        
                    } label: {
                        VStack {
                            Image(systemName: "plus")
                        }
                        .frame(maxWidth: 75, maxHeight: .infinity)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    let inAllUsers = allUsers.contains(where: { $0.id == playerId })
                    let inGamePlayers = game.players.contains(where: { $0.id == playerId })
                    let isAlreadyAdded = inAllUsers && inGamePlayers
                    
                    Button {
                        if !inAllUsers {
                            showNewPlayerAlert = true
                        } else if inAllUsers && !inGamePlayers {
                            isVerifiedUser = true
                            showErrorAlert = false
                        } else if isAlreadyAdded {
                            showErrorAlert = true
                            errorMessage = "Player already added"
                        } else {
                            showErrorAlert = true
                            errorMessage = "Player not found"
                        }
                        
                        
                    } label: {
                        Text("Verify")
                            .font(.subheadline).bold()
                            .frame(maxWidth: 75, maxHeight: .infinity)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(8)
                    }
                    .frame(maxHeight: .infinity)
                    .alert("Error", isPresented: $showErrorAlert) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text(errorMessage)
                    }
                    .alert("Create Player", isPresented: $showNewPlayerAlert) {
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
                            firestoreService.createUser(id: playerId, pin: playerPin) { _ in }
                            let newPlayer = Player(id: playerId, buyIn: 5.00, cashOut: 0.00, profit: 0.00)
                            let transaction = Transaction(id: game.events.count, description: "player joined", from: "BANK", to: playerId, amount: String(format: "%.2f", newPlayer.buyIn))
                            game.players.append(newPlayer)
                            logEvent(newEvent: transaction)
                            playerId = ""
                        }
                        .disabled(isOKDisabled)
                        
                        Button("Cancel", role: .cancel) {
                            playerId = ""
                        }
                    } message: {
                        Text("Player must set a 3-10 digit pin.\nIt will be used as their login credentials.")
                    }
                }
            }
            .frame(maxHeight: .infinity)
            
            
        }
        .padding(.vertical, 5)
        
        Divider()
            .onAppear {
                firestoreService.fetchUsers { users in
                    allUsers = users
                }
            }
    }
}
