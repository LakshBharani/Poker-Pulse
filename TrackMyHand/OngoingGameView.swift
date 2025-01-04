//
//  OngoingGameView.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 21/12/24.
//

import SwiftUI

struct OngoingGameView: View {
    
    @ObservedObject private var timer = MyTimer()
    @State private var isClockStarted: Bool = false
    @StateObject private var firestoreService = FirestoreService()
    @State var transactionFrom: String = ""
    @State var transactionTo: String = ""
    @State var transactionAmount: String = ""
    @State private var isMakingTransaction: Bool = false
    @State private var isGameOver: Bool = false
    @State private var isShowingGameOverAlert: Bool = false
    @State private var isShowingCashOutAlert: Bool = false
    @State private var isReadyToCashOut: Bool = false
    @State private var cashoutAmt: Double = 0.0
    @State private var cashOutLog: [Transaction] = []
    
    @State var game: Game
    var allUsers: [User]
    
    var body: some View {
        
        NavigationStack {
            ScrollView(showsIndicators: false) {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 30)
                    .foregroundStyle(.gray).opacity(0.2)
                    .overlay(
                        ZStack {
                            HStack {
                                Text("Game Code")
                                    .foregroundStyle(.orange)
                                    .bold()
                                    .font(.system(size: 12))
                                Spacer()
                                Text(isGameOver ? "Game Over" : "In progress")
                                    .foregroundStyle(isGameOver ? .red : .green)
                                    .bold()
                                    .font(.system(size: 12))
                            }
                            .padding(.horizontal)
                            
                            Text(game.gameCode)
                                .foregroundStyle(.orange)
                                .bold()
                                .font(.system(size: 12))
                        }
                    )
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 100)
                    .foregroundStyle(.gray).opacity(0.2)
                    .background(
                        Text(String(format: "%02d : %02d : %02d", timer.hoursElapsed, timer.minutesElapsed, timer.secondsElapsed))
                            .foregroundStyle(.orange)
                            .bold()
                            .font(.system(size: 60))
                    )
                    .onAppear {
                        if !(game.players.contains(where: { $0.id == "BANK" })) {
                            game.players.insert(Player(id: "BANK", buyIn: 0, cashOut: 0, profit: 0), at: 0)
                        }
                        for player in game.players {
                            game.events.append(Transaction(id: game.events.count, description: "Initial BuyIn", from: "BANK", to: player.id, amount: "5.00"))
                        }
                        transactionFrom = game.players.first!.id
                        transactionTo = game.players.first!.id
                    }
                
                HStack {
                    if isGameOver {
                        Text("Buy-In ($)")
                            .foregroundStyle(.white).opacity(0.45)
                            .font(.subheadline)
                        Divider()
                            .padding(.horizontal, 2)
                        Spacer()
                        Text("\(game.totalPot, specifier: "%.2f")")
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(.orange)
                        Spacer()
                        Divider()
                        Spacer()
                        Text("Cashout ($)")
                            .foregroundStyle(.white).opacity(0.45)
                            .font(.subheadline)
                        Spacer()
                        Divider()
                            .padding(.horizontal, 2)
                        Spacer()
                        Text("\(cashoutAmt, specifier: "%.2f")")
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(.orange)
                        Spacer()
                    } else {
                        Text("Total Pot ($)")
                            .foregroundStyle(.white).opacity(0.45)
                        Divider()
                            .padding(.horizontal)
                        Spacer()
                        Text("\(game.totalPot, specifier: "%.2f")")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.orange)
                    }
                }
                .frame(height: 30)
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
                
                
                if (isMakingTransaction || isGameOver) {
                    VStack(alignment: .leading) {
                        VStack {
                            // Transaction Pickers
                            HStack(alignment: .center) {
                                Menu {
                                    Picker("From", selection: $transactionFrom) {
                                        ForEach(game.players, id: \.self.id) { player in
                                            Text(player.id)
                                                .font(.subheadline)
                                                .lineLimit(1)
                                        }
                                    }
                                } label: {
                                    Text(transactionFrom)
                                        .lineLimit(1)
                                }
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .foregroundStyle(.gray)
                                    .frame(alignment: .bottom)
                                Spacer()
                                Menu {
                                    if !isGameOver {
                                        Picker("To", selection: $transactionTo) {
                                            ForEach(game.players, id: \.self.id) { player in
                                                Text(player.id)
                                                    .font(.subheadline)
                                                    .lineLimit(1)
                                            }
                                        }
                                    } else {
                                        Text("BANK")
                                    }
                                    
                                } label: {
                                    Text(transactionTo)
                                        .lineLimit(1)
                                }
                                Divider()
                                    .padding(.leading)
                                HStack {
                                    TextField("Amount", text: $transactionAmount)
                                        .keyboardType(.decimalPad)
                                    Text("$")
                                        .foregroundStyle(.white).opacity(0.45)
                                }
                                .frame(width: 80)
                            }
                            .padding()
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(.gray).opacity(0.2)
                        }
                        
                        // Button Bar
                        HStack {
                            if !isGameOver {
                                Button(action: {
                                    isMakingTransaction = false
                                }, label: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundStyle(.red).opacity(0.2)
                                        .frame(height: 50)
                                        .overlay(content: {
                                            Text("Cancel")
                                                .font(.subheadline)
                                                .foregroundStyle(.red)
                                        })
                                })
                            }
                            
                            Button(action: {
                                var desc = ""
                                if isGameOver {
                                    desc = "cashout"
                                } else if transactionTo == "BANK" {
                                    desc = "ingame-cashout"
                                } else {
                                    desc = "buyin"
                                }
                                let id = !isGameOver ? game.events.count : game.events.count + cashOutLog.count
                                let formattedAmount = String(format: "%.2f", Double(transactionAmount) ?? 0.0).trimmingCharacters(in: .whitespacesAndNewlines)
                                let event = Transaction(id: id, description: desc, from: transactionFrom, to: transactionTo, amount: formattedAmount)
                                logEvent(newEvent: event)
                                isMakingTransaction = false
                                transactionAmount = ""
                            }, label: {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(.blue).opacity(0.2)
                                    .frame(height: 50)
                                    .overlay(content: {
                                        Text("Confirm")
                                            .font(.subheadline)
                                            .foregroundStyle(.blue)
                                    })
                            })
                            .disabled((transactionFrom == transactionTo) || (transactionAmount == ""))
                        }
                    }
                    
                } else {
                    if (!isClockStarted) {
                        if !isGameOver {
                            HStack {
                                Button(action: {
                                    isClockStarted = true
                                    timer.start(firestoreService: firestoreService, game: game)
                                }, label: {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(timer.secondsElapsed > 0 ? .orange : .gray).opacity(0.2)
                                        .frame(height: 70)
                                        .overlay(content: {
                                            Text(timer.secondsElapsed > 0 ? "Resume Game" : "Start Game")
                                                .foregroundStyle(.orange)
                                                .font(.system(size: 18, weight: .semibold))
                                        })
                                })
                                
                                Button(action: {
                                    game.timeElapsed = [timer.hoursElapsed, timer.minutesElapsed, timer.secondsElapsed]
                                    isClockStarted = false
                                    timer.stop()
                                    isShowingGameOverAlert = true
                                }, label: {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(.red).opacity(0.2)
                                        .frame(height: 70)
                                        .overlay(content: {
                                            Text("End Game")
                                                .foregroundStyle(.red)
                                                .font(.system(size: 18, weight: .semibold))
                                        })
                                })
                                .alert("End Game", isPresented: $isShowingGameOverAlert) {
                                    Button("Cancel", role: .cancel) {}
                                    Button("Confirm") {
                                        if game.timeElapsed == [0, 0, 0] {
                                            isReadyToCashOut = true
                                        }
                                        isGameOver = true
                                        let event = Transaction(id: game.events.count, description: "game over", from: "", to: "", amount: "")
                                        logEvent(newEvent: event)
                                    }
                                } message: {
                                    Text("This action cannot be undone")
                                }
                                
                            }
                        }
                        
                    } else {
                        HStack {
                            Button(action: {
                                isClockStarted = false
                                timer.stop()
                            }, label: {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(.red).opacity(0.2)
                                    .frame(height: 70)
                                    .overlay(content: {
                                        Text("Pause Game")
                                            .foregroundStyle(.red)
                                            .font(.system(size: 18, weight: .semibold))
                                    })
                            })
                            
                            Button(action: {
                                isMakingTransaction = true
                            }, label: {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(.green).opacity(0.2)
                                    .frame(height: 70)
                                    .overlay(content: {
                                        Text("Transaction")
                                            .foregroundStyle(.green)
                                            .font(.system(size: 18, weight: .semibold))
                                    })
                            })
                        }
                    }
                }
                
                Section(header: HStack {
                    Text("Players (\(isGameOver ? game.players.count : game.players.count - 1))")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Buy In ($)")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text("Profit ($)")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                    .padding(.horizontal)
                    .padding(.top, 10)) {
                        ForEach(game.players) { player in
                            if (player.id != "BANK") {
                                PlayerDataRow(player: player)
                            }
                        }
                        Divider()
                    }
                
                if !isGameOver {
                    PlayerManagementBar(game: $game, allUsers: allUsers)
                } else {
                    HStack {
                        Button(action: {
                            if game.totalPot != cashoutAmt {
                                isShowingCashOutAlert = true
                                return
                            }
                            game.timeElapsed = [timer.hoursElapsed, timer.minutesElapsed, timer.secondsElapsed]
                            firestoreService.updateGameStatusOnEnd(game: game) { result in
                                if result != nil {
                                    print("Game Over")
                                }
                            }
                            if game.timeElapsed != [0, 0, 0] {
                                Task {
                                    await firestoreService.updateUserStatsOnGameEnd(game: game) { _ in
                                        print("Game ended")
                                    }
                                }
                            }
                            game.players.removeAll(where: { $0.id == "BANK" })
                            isReadyToCashOut = true
                        }, label: {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(.red).opacity(0.2)
                                .frame(height: 50)
                                .overlay(content: {
                                    Text("Cashout & Exit")
                                        .font(.subheadline)
                                        .foregroundStyle(.red)
                                })
                        })
                        .alert("Incorrect Cashout", isPresented: $isShowingCashOutAlert) {
                        } message: {
                            Text("Buy-In not equal to Cashout.\nPlease check again.")
                        }
                    }
                    .navigationDestination(isPresented: $isReadyToCashOut) {
                        ContentView()
                    }
                }
                
                
                EventLogger(game: game, cashOutLog: cashOutLog)
            }
            .padding(.horizontal)
            .navigationBarBackButtonHidden(true)
        }
        
    }
    
    func logEvent(newEvent: Transaction) {
        let description = newEvent.description
        if description == "buyin" || description == "ingame-cashout" {
            if let playerIndex = game.players.firstIndex(where: { $0.id == newEvent.to }) {
                game.players[playerIndex].profit -= Double(newEvent.amount)!
                game.players[playerIndex].buyIn += Double(newEvent.amount)!
            }
            
            if let playerIndex = game.players.firstIndex(where: { $0.id == newEvent.from }) {
                game.players[playerIndex].profit += Double(newEvent.amount)!
            }
            
            game.events.append(newEvent)
            
            if newEvent.to != "BANK" {
                game.totalPot += Double(newEvent.amount)!
            }
            
            if newEvent.description == "ingame-cashout" {
                cashoutAmt += Double(newEvent.amount)!
            }
            
        
        } else if description == "game over" {
            game.events.append(newEvent)
            
        } else if description == "cashout" {
            let playerToIndex = game.players.firstIndex(where: { $0.id == newEvent.to })
            let playerFromIndex = game.players.firstIndex(where: { $0.id == newEvent.from })
            
            if (playerToIndex != nil) {
                game.players[playerToIndex!].profit -= Double(newEvent.amount)!
                game.players[playerToIndex!].buyIn += Double(newEvent.amount)!
            }
            
            if (playerFromIndex != nil) {
                game.players[playerFromIndex!].profit += Double(newEvent.amount)!
            }
            
            var modifiedEvent = newEvent
            if let index = cashOutLog.firstIndex(where: { $0.from == newEvent.from }) {
                cashoutAmt -= Double(cashOutLog[index].amount)!
                game.players[playerFromIndex!].profit -= Double(cashOutLog[index].amount)!
                cashOutLog.remove(at: index)
                modifiedEvent.id = index + game.events.count
                cashOutLog.insert(modifiedEvent, at: index)
            } else {
                cashOutLog.append(newEvent)
            }
            
            cashoutAmt += Double(newEvent.amount)!
        }
        
        
        firestoreService.updateGameOnEvent(game: game) { result in
            if result != nil {
                print("Game Updated")
            }
        }
    }
}

struct EventLogger : View {
    var game: Game
    var cashOutLog: [Transaction]

    var body: some View {
        let allEvents = game.events + cashOutLog
        Section(header: HStack {
            Text("Event Log (\(allEvents.count - 1))")
                .font(.subheadline)
                .foregroundStyle(.gray)
            Spacer()
            Text("Exchanged ($)")
                .font(.subheadline)
                .foregroundStyle(.gray)
            }
            .padding(.bottom, 5)
            .padding(.top)
            .frame(maxWidth: .infinity, alignment: .leading)
        ) {
            ForEach(allEvents.reversed()) { event in
                if event.description == "game over" {
                    HStack {
                        Text("\(event.time.formatted(date: .omitted, time: .shortened))")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .frame(width: 65)
                        Divider()
                            .padding(.trailing, 2)
                        Text("Game Over")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                        Spacer()
                    }
                    Divider()
                        .padding(.trailing, 2)
                        .padding(.vertical, 1)
                }
                else if event.amount != "0.00" && event.from != event.to {
                    HStack {
                        Text("\(event.time.formatted(date: .omitted, time: .shortened))")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .frame(width: 65)
                        Divider()
                            .padding(.trailing, 2)
                        Text("\(event.from)")
                            .foregroundStyle(event.description.contains("cashout") ? .mint : .white)
                            .font(.subheadline)
                            .lineLimit(1)
                        Image(systemName: "arrow.right")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("\(event.to)")
                            .foregroundStyle(event.description.contains("cashout") ? .mint : .white)
                            .font(.subheadline)
                            .lineLimit(1)
                        Spacer()
                        Divider()
                            .padding(.horizontal, 2)
                        Text("\(event.amount)")
                            .lineLimit(1)
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(event.description.contains("cashout") ? .mint : .orange)
                            .frame(width: 60)
                    }
                }
            }
        }
    }
}



struct PlayerDataRow: View {
    var player: Player
    var body: some View {
        var profitColor: Color {
            if player.profit >= 0 {
                .green
            } else {
                .red
            }
        }
        
        VStack {
            Divider()
            HStack {
                Text("\(player.id)")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(player.buyIn, specifier: "%.2f")")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("\(player.profit, specifier: "%.2f")")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(profitColor)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.vertical, 0.1)
        }
        .padding(.horizontal)
    }
}


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


class MyTimer : ObservableObject {
    @Published var hoursElapsed = 0
    @Published var minutesElapsed = 0
    @Published var secondsElapsed = 0

    var timer = Timer()
    
    func start(firestoreService: FirestoreService, game: Game) {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            self.secondsElapsed += 1
            if self.secondsElapsed == 60 {
                self.minutesElapsed += 1
                self.secondsElapsed = 0
            }
            if self.minutesElapsed == 60 {
                self.hoursElapsed += 1
                self.minutesElapsed = 0
            }
            let updatedTimeElapsed = [self.hoursElapsed, self.minutesElapsed, self.secondsElapsed]
            var updatedGame = game
            updatedGame.timeElapsed = updatedTimeElapsed
            
            firestoreService.updateIngameClock(game: updatedGame) { _ in }
        }
    }
    
    func stop() {
        timer.invalidate()
    }
}

#Preview {
    OngoingGameView(game: Game(isActive: true, id: "7B97E339-3EEF-4431-B6A7-85681B64D002", timeElapsed: [0, 0, 0], gameCode: "7B9002", totalPot: 40.0, date: Date(), players: [TrackMyHand.Player(id: "LAKSH", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "ATHARV", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "SAHAJ", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "USMAAN", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "AREEB", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "SAIF", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "ANIRUDH", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "LAKSHYA", buyIn: 5.0, cashOut: 0.0, profit: -5.0)], events: []),
                    
                    allUsers: [TrackMyHand.User(id: "ANIRUDH", totalProfit: 30.0, isFavorite: false, profitData: [0.0, 10.0, 7.0, 14.5, 30.0], totalWins: 3, timePlayed: 0, totalBuyIn: 45.0), TrackMyHand.User(id: "VIBHAV", totalProfit: 0.0, isFavorite: false, profitData: [0.0], totalWins: 0, timePlayed: 0, totalBuyIn: 0.0), TrackMyHand.User(id: "USMAAN", totalProfit: 0.0, isFavorite: false, profitData: [0.0], totalWins: 0, timePlayed: 0, totalBuyIn: 0.0), TrackMyHand.User(id: "SIDAK", totalProfit: 0.0, isFavorite: false, profitData: [0.0], totalWins: 0, timePlayed: 0, totalBuyIn: 0.0), TrackMyHand.User(id: "SAIF", totalProfit: 0.0, isFavorite: false, profitData: [0.0], totalWins: 0, timePlayed: 0, totalBuyIn: 0.0), TrackMyHand.User(id: "SAHAJ", totalProfit: 0.0, isFavorite: false, profitData: [0.0], totalWins: 0, timePlayed: 0, totalBuyIn: 0.0), TrackMyHand.User(id: "LAKSHYA", totalProfit: 0.0, isFavorite: false, profitData: [0.0], totalWins: 0, timePlayed: 0, totalBuyIn: 0.0), TrackMyHand.User(id: "LAKSH", totalProfit: 0.0, isFavorite: false, profitData: [0.0], totalWins: 0, timePlayed: 0, totalBuyIn: 0.0), TrackMyHand.User(id: "ATHARV", totalProfit: 0.0, isFavorite: false, profitData: [0.0], totalWins: 0, timePlayed: 0, totalBuyIn: 0.0), TrackMyHand.User(id: "AREEB", totalProfit: 0.0, isFavorite: false, profitData: [0.0], totalWins: 0, timePlayed: 0, totalBuyIn: 0.0)])
}
