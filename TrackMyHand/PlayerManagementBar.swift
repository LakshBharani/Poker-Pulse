//
//  PlayerManagementBar.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 05/01/25.
//

import SwiftUI

struct PlayerManagementBar: View {
    @StateObject private var firestoreService = FirestoreService()
    @State private var isPlayerIdAlertShown: Bool = false
    @State private var isNewPlayerAlertShown: Bool = false
    @State private var playerId: String = ""
    @State private var isDisabled: Bool = true
    @Binding var game: Game
    var allUsers: [User]
    
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
        HStack {
            Button(action: {
                isPlayerIdAlertShown = true
            }) {
                HStack {
                    Label("Add Player", systemImage: "plus.circle")
                        .font(.headline)
                        .padding()
                    Spacer()
                }
                .padding(.trailing)
            }
            .foregroundStyle(.orange)
            .background(RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.gray)
                .opacity(0.2)
            )
            .alert("Add Player", isPresented: $isPlayerIdAlertShown) {
                TextField("Enter player ID", text: $playerId)
                    .autocorrectionDisabled(true)
                    .onChange(of: playerId) { oldValue, newValue in
                        playerId = newValue.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        isDisabled = playerId.isEmpty ||
                                     game.players.contains(where: { $0.id == playerId }) ||
                                     !allUsers.contains(where: { $0.id == playerId })
                    }
                
                Button("OK") {
                    let newPlayer = Player(id: playerId, buyIn: 5.00, cashOut: 0.00, profit: 0.00)
                    let transaction = Transaction(id: game.events.count, description: "player joined", from: "BANK", to: playerId, amount: String(format: "%.2f", newPlayer.buyIn))
                    game.players.append(newPlayer)
                    logEvent(newEvent: transaction)
                    playerId = ""
                }
                .disabled(isDisabled)
                
                Button("Cancel", role: .cancel) {
                    playerId = ""
                }
            }
            
            Button(action: {
                isNewPlayerAlertShown = true
            }) {
                Image(systemName: "person.crop.circle.fill.badge.plus")
                    .foregroundStyle(.blue)
                    .font(.system(size: 22))
                    .frame(width: 50, height: 50)
            }
            .background(RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.gray)
                .opacity(0.2)
            )
            .alert("Create New Player", isPresented: $isNewPlayerAlertShown) {
                TextField("Create player ID", text: $playerId)
                    .autocorrectionDisabled(true)
                    .onChange(of: playerId) { oldValue, newValue in
                        playerId = newValue.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                
                Button("Create") {
                    let newPlayer = Player(id: playerId, buyIn: 5.00, cashOut: 0.00, profit: 0.00)
                    game.players.append(newPlayer)
                    let transaction = Transaction(id: game.events.count, description: "player joined", from: "BANK", to: playerId, amount: String(format: "%.2f", newPlayer.buyIn))
                    logEvent(newEvent: transaction)
                    playerId = ""
                    firestoreService.createUser(id: newPlayer.id) {_ in }
                }
                .disabled(playerId.isEmpty ||
                          allUsers.contains(where: { $0.id == playerId }))
                
                Button("Cancel", role: .cancel) {
                    playerId = ""
                }
            }
        }
        Divider()
    }
}
