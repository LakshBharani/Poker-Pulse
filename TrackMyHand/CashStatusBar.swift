//
//  CashStatusBar.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 05/01/25.
//

import SwiftUI

struct CashStatusBar: View {
    var game: Game
    
    var body: some View {
        HStack {
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
            Text("\(game.cashOut, specifier: "%.2f")")
                .font(.subheadline)
                .bold()
                .foregroundStyle(.orange)
            Spacer()
            
        }
        .frame(height: 30)
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
    }
}

#Preview {
    let game = Game(isActive: true, isGameEnded: false, id: "7B97E339-3EEF-4431-B6A7-85681B64D002", timeElapsed: [0, 0, 0], gameCode: "7B9002", totalPot: 40.0, cashOut: 0, date: Date(), players: [TrackMyHand.Player(id: "LAKSH", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "ATHARV", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "SAHAJ", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "USMAAN", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "AREEB", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "SAIF", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "ANIRUDH", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "LAKSHYA", buyIn: 5.0, cashOut: 0.0, profit: -5.0)], events: [])
    CashStatusBar(game: game)
}
