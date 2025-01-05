//
//  OngoingGameView.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 21/12/24.
//

import SwiftUI

struct OngoingGameView: View {
    private enum Field: Int, CaseIterable {
        case amount
    }
    
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
    @State private var gameStatus: String = ""
    @State var game: Game
    @FocusState private var focusedField: Field?
    var allUsers: [User]
    
    var body: some View {
        @StateObject var gameViewModel = GameViewModel(game: game)
        
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
                            
                                
                                Text(gameStatus)
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
                    .padding(.top)
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 100)
                    .foregroundStyle(.gray).opacity(0.2)
                    .background(
                        Text(game.isActive ?
                             String(format: "%02d : %02d : %02d", timer.hoursElapsed, timer.minutesElapsed, timer.secondsElapsed)
                             : String(format: "%02d : %02d : %02d", game.timeElapsed[0], game.timeElapsed[1], game.timeElapsed[2]))
                            .foregroundStyle(.orange)
                            .bold()
                            .font(.system(size: 60))
                    )
                    .onAppear {
                        if game.isActive {
                            gameStatus = isGameOver ? "Game Over" : "In progress"
                            if game.timeElapsed == [0, 0, 0] {
                                if !(game.players.contains(where: { $0.id == "BANK" })) {
                                    game.players.insert(Player(id: "BANK", buyIn: 0, cashOut: 0, profit: 0), at: 0)
                                }
                                for player in game.players {
                                    game.events.append(Transaction(id: game.events.count, description: "Initial BuyIn", from: "BANK", to: player.id, amount: "5.00"))
                                }
                                logEvent(newEvent: Transaction(id: game.events.count, description: "Players Joined", from: "", to: "", amount: ""))
                            } else {
                                timer.hoursElapsed = game.timeElapsed[0]
                                timer.minutesElapsed = game.timeElapsed[1]
                                timer.secondsElapsed = game.timeElapsed[2]
                                isGameOver = false
                            }
                        } else {
                            gameStatus = "Summary"
                            isGameOver = false
                            
                        }
                        transactionFrom = game.players.first!.id
                        transactionTo = game.players.first!.id
                    }
                                
                CashStatusBar(game: game, isGameOver: isGameOver)
                
                if game.isActive {
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
                                        Picker("To", selection: $transactionTo) {
                                            let selectedList = !isGameOver ? game.players : Array(game.players.prefix(1))
                                            ForEach(selectedList, id: \.self.id) { player in
                                                Text(player.id)
                                                    .font(.subheadline)
                                                    .lineLimit(1)
                                            }
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
                                            .focused($focusedField, equals: .amount)
                                            .toolbar {
                                                ToolbarItem(placement: .keyboard) {
                                                    Button("Done") {
                                                        focusedField = nil
                                                    }
                                                }
                                            }
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
                                    let formattedAmount = String(format: "%.2f", Double(transactionAmount) ?? 0.0).trimmingCharacters(in: .whitespacesAndNewlines)
                                    let event = Transaction(id: game.events.count, description: desc, from: transactionFrom, to: transactionTo, amount: formattedAmount)
                                    logEvent(newEvent: event)
                                    isMakingTransaction = false
                                    transactionAmount = ""
                                    gameViewModel.recalculatePredictions()
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
                        if (!isClockStarted && !isGameOver) {
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
                                        firestoreService.updateGameStatusOnEnd(game: game) { result in
                                            if result != nil {
                                                print("Game Over")
                                            }
                                        }
                                        if game.timeElapsed == [0, 0, 0] {
                                            isReadyToCashOut = true
                                        }
                                        transactionTo = "BANK"
                                        isGameOver = true
                                        let event = Transaction(id: game.events.count, description: "game over", from: "", to: "", amount: "")
                                        logEvent(newEvent: event)
                                    }
                                } message: {
                                    Text("This action cannot be undone")
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
                        
                        PredictionBarView(gameViewModel: gameViewModel)

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
                
                if game.isActive {
                    if !isGameOver {
                        PlayerManagementBar(game: $game, allUsers: allUsers)
                    } else {
                        HStack {
                            Button(action: {
                                if game.totalPot != game.cashOut {
                                    isShowingCashOutAlert = true
                                    return
                                }
                                game.timeElapsed = [timer.hoursElapsed, timer.minutesElapsed, timer.secondsElapsed]
                                logEvent(newEvent: Transaction(id: game.events.count, description: "Exit", from: "", to: "", amount: ""))
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
                }
                
                
                EventLogger(game: game)
            }
            .padding(.horizontal)
            .navigationBarBackButtonHidden(game.isActive)
        }
        .navigationTitle("Game Summary")
        .toolbar(game.isActive ? .hidden : .visible)
        
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
                game.cashOut += Double(newEvent.amount)!
            }
            
        
        } else if description == "game over" {
            if game.events.count(where: { $0.description == "game over" }) == 0 {
                game.events.append(newEvent)
            }
                        
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
            if let index = game.events.firstIndex(where: { $0.from == newEvent.from && $0.description == "cashout" }) {
                game.cashOut -= Double(game.events[index].amount)!
                game.players[playerFromIndex!].profit -= Double(game.events[index].amount)!
                game.events.remove(at: index)
                modifiedEvent.id = index
                game.events.insert(modifiedEvent, at: index)
            } else {
                game.events.append(newEvent)
            }
            
            game.cashOut += Double(newEvent.amount)!
        }
        
        
        firestoreService.updateGameOnEvent(game: game) { result in
            if result != nil {
                print("Game Updated")
            }
        }
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
    OngoingGameView(game: Game(isActive: true, id: "7B97E339-3EEF-4431-B6A7-85681B64D002", timeElapsed: [0, 0, 0], gameCode: "7B9002", totalPot: 40.0, cashOut: 0, date: Date(), players: [TrackMyHand.Player(id: "LAKSH", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "ATHARV", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "SAHAJ", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "USMAAN", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "AREEB", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "SAIF", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "ANIRUDH", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "LAKSHYA", buyIn: 5.0, cashOut: 0.0, profit: -5.0)], events: []),
                    
                    allUsers: [TrackMyHand.User(id: "ANIRUDH", totalProfit: 30.0, isFavorite: false, profitData: [0.0, 10.0, 7.0, 14.5, 30.0], totalWins: 3, timePlayed: 0, totalBuyIn: 45.0), TrackMyHand.User(id: "VIBHAV", totalProfit: 0.0, isFavorite: false, profitData: [0.0], totalWins: 0, timePlayed: 0, totalBuyIn: 0.0), TrackMyHand.User(id: "USMAAN", totalProfit: 0.0, isFavorite: false, profitData: [0.0], totalWins: 0, timePlayed: 0, totalBuyIn: 0.0), TrackMyHand.User(id: "SIDAK", totalProfit: 0.0, isFavorite: false, profitData: [0.0], totalWins: 0, timePlayed: 0, totalBuyIn: 0.0), TrackMyHand.User(id: "SAIF", totalProfit: 0.0, isFavorite: false, profitData: [0.0], totalWins: 0, timePlayed: 0, totalBuyIn: 0.0), TrackMyHand.User(id: "SAHAJ", totalProfit: 0.0, isFavorite: false, profitData: [0.0], totalWins: 0, timePlayed: 0, totalBuyIn: 0.0), TrackMyHand.User(id: "LAKSHYA", totalProfit: 0.0, isFavorite: false, profitData: [0.0], totalWins: 0, timePlayed: 0, totalBuyIn: 0.0), TrackMyHand.User(id: "LAKSH", totalProfit: 0.0, isFavorite: false, profitData: [0.0], totalWins: 0, timePlayed: 0, totalBuyIn: 0.0), TrackMyHand.User(id: "ATHARV", totalProfit: 0.0, isFavorite: false, profitData: [0.0], totalWins: 0, timePlayed: 0, totalBuyIn: 0.0), TrackMyHand.User(id: "AREEB", totalProfit: 0.0, isFavorite: false, profitData: [0.0], totalWins: 0, timePlayed: 0, totalBuyIn: 0.0)])
}
