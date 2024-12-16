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
    
    
    // Game details
    @State private var allPlayers: [Player] = []
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                // Section for player details
                Section(header: Text("Players")) {
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

                    ForEach(allPlayers) { player in
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
                    
                    if (!isAllPlayersExisting && !newPlayerUID.isEmpty) {
                        Button(action: {
                            showAlert = true
                        }) {
                            Label("Create User", systemImage: "person.crop.circle.fill.badge.plus")
                                .foregroundStyle(.red)
                        }
                        .alert("Create new user?", isPresented: $showAlert) {
                            Button("Yes") {
                                newPlayerUID = newPlayerUID.trimmingCharacters(in: .whitespacesAndNewlines)
                                firestoreService.createUser(id: newPlayerUID) {_ in}
                                allUsers.append(User(id: newPlayerUID, totalProfit: 0, gamesPlayed: 0))
                                allPlayers.append(Player(id: newPlayerUID, buyIn: 5, cashOut: 0, profit: 0))
                                newPlayerUID = ""
                                isAllPlayersExisting = true
                            }
                            
                            Button("Cancel", role: .cancel) {
                                
                            }
                            .foregroundStyle(.red)
                        }
                    }
                    
                    
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
                    .disabled(!isAllPlayersUnique || !isAllPlayersExisting)
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
                        let newGame = Game(
                            id: UUID().uuidString,
                            date: Date(),
                            players: allPlayers,
                            transactions: []
                        )
                        firestoreService.createGame(game: newGame) { error in
                            if let error = error {
                                print("Error saving game: \(error.localizedDescription)")
                            } else {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .disabled(allPlayers.count < 2)
                }
            }
            .navigationTitle("Create Game")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            
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



