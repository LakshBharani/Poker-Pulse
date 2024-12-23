//
//  OngoingGameView.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 21/12/24.
//

import SwiftUI

struct OngoingGameView: View {
    @ObservedObject var timer = MyTimer()
    @State var isClockStarted: Bool = false
    
    var game: Game
    var body: some View {
        ScrollView {
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 100)
                .foregroundStyle(.gray).opacity(0.2)
                .background(
                    Text(String(format: "%02d : %02d : %02d", timer.hoursElapsed, timer.minutesElapsed, timer.secondsElapsed))
                        .foregroundStyle(.orange)
                        .bold()
                        .font(.system(size: 60))
                )
            
            HStack {
                Text("Total Pot ($)")
                Divider()
                    .padding(.horizontal)
                Spacer()
                Text("\(game.totalPot, specifier: "%.2f")")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.orange)
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
            
            if (!isClockStarted) {
                Button(action: {
                    isClockStarted = true
                    timer.start()
                }, label: {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(timer.secondsElapsed > 0 ? .orange : .gray).opacity(0.2)
                        .frame(height: 75)
                        .overlay(content: {
                            Text(timer.secondsElapsed > 0 ? "Resume Game" : "Start Game")
                                .foregroundStyle(.orange)
                                .font(.system(size: 18, weight: .semibold))
                        })
                })
            } else {
                HStack {
                    Button(action: {
                        isClockStarted = false
                        timer.stop()
                    }, label: {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.red).opacity(0.2)
                            .frame(height: 75)
                            .overlay(content: {
                                Text("Pause Game")
                                    .foregroundStyle(.red)
                                    .font(.system(size: 18, weight: .semibold))
                            })
                    })
                    
                    Button(action: {
                        
                    }, label: {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.green).opacity(0.2)
                            .frame(height: 75)
                            .overlay(content: {
                                Text("Transaction")
                                    .foregroundStyle(.green)
                                    .font(.system(size: 18, weight: .semibold))
                            })
                    })
                }
            }
            
            Section(header: HStack {
                Text("Players (\(game.players.count))")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                Spacer()
                Text("Buy In ($)")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                
            }.padding(.top, 10)) {
                ForEach(game.players) { player in
                    VStack {
                        Divider()
                        HStack {
                            Text("\(player.id)")
                                .font(.subheadline)
                            Spacer()
                            Text("\(player.buyIn, specifier: "%.2f")")
                                .font(.subheadline)
                                .bold()
                                .foregroundStyle(.orange)
                        }
                        .padding(.vertical, 0.1)
                        
                    }
                    .padding(.horizontal)
                }
                Divider()
            }
            
            Button(action: {
                
            }) {
                HStack {
                    Label("Add Player", systemImage: "plus.circle")
                        .font(.headline)
                        .padding()
                    Spacer()
                }
            }
            .foregroundStyle(.orange)
            .background(RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.gray)
                .opacity(0.2)
            )
            
        }
        .padding(.horizontal)
        .navigationBarBackButtonHidden(true)
    }
}

class MyTimer : ObservableObject {
    @Published var hoursElapsed = 0
    @Published var minutesElapsed = 0
    @Published var secondsElapsed = 0
    var timer = Timer()
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.secondsElapsed += 1
            if self.secondsElapsed >= 60 {
                if self.minutesElapsed >= 60 {
                    self.hoursElapsed += 1
                    self.minutesElapsed = 0
                }
                self.minutesElapsed += 1
                self.secondsElapsed = 0
            }
        }
    }
    
    func stop() {
        timer.invalidate()
    }
}

#Preview {
    OngoingGameView(game: Game(isActive: true, id: "7B97E339-3EEF-4431-B6A7-85681B64D002", gameCode: "7B9002", totalPot: 40.0, date: Date(), players: [TrackMyHand.Player(id: "LAKSH", buyIn: 5.0, cashOut: 0.0, profit: 0.0), TrackMyHand.Player(id: "ATHARV", buyIn: 5.0, cashOut: 0.0, profit: 0.0), TrackMyHand.Player(id: "SAHAJ", buyIn: 5.0, cashOut: 0.0, profit: 0.0), TrackMyHand.Player(id: "USMAAN", buyIn: 5.0, cashOut: 0.0, profit: 0.0), TrackMyHand.Player(id: "AREEB", buyIn: 5.0, cashOut: 0.0, profit: 0.0), TrackMyHand.Player(id: "SAIF", buyIn: 5.0, cashOut: 0.0, profit: 0.0), TrackMyHand.Player(id: "ANIRUDH", buyIn: 5.0, cashOut: 0.0, profit: 0.0), TrackMyHand.Player(id: "LAKSHYA", buyIn: 5.0, cashOut: 0.0, profit: 0.0)], transactions: []))
}
