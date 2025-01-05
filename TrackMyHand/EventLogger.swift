//
//  EventLogger.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 05/01/25.
//

import SwiftUI

struct EventLogger : View {
    var game: Game

    var body: some View {
        let allEvents = game.events
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
                            .foregroundStyle(.red)
                        Spacer()
                    }
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


#Preview {
    EventLogger(game: Game(isActive: true, id: "7B97E339-3EEF-4431-B6A7-85681B64D002", timeElapsed: [0, 0, 0], gameCode: "7B9002", totalPot: 40.0, cashOut: 0, date: Date(), players: [TrackMyHand.Player(id: "LAKSH", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "ATHARV", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "SAHAJ", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "USMAAN", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "AREEB", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "SAIF", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "ANIRUDH", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "LAKSHYA", buyIn: 5.0, cashOut: 0.0, profit: -5.0)], events: []))
}
