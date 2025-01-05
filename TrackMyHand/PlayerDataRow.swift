//
//  PlayerDataRow.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 05/01/25.
//

import SwiftUI

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

#Preview {
    PlayerDataRow(player: Player(id: "LAKSH", buyIn: 5, cashOut: 5, profit: 10))
}
