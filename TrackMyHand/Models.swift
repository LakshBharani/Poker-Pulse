//
//  Models.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 21/11/24.
//

import Foundation

struct Player: Identifiable, Codable {
    var id: String { player_id }
    var player_id: String
    var name: String
    var email: String
    var buy_ins: [Transaction]
    var cash_outs: [Transaction]
    var net_cash: Int
    var settled: Bool
}

struct Transaction: Codable {
    var amount: Int
    var time: String
    var from: String?
    var to: String?
    var reason: String?
}

struct Game: Identifiable, Codable {
    var id: String { game_id }
    var game_id: String
    var date: String
    var location: String
    var players: [Player]
    var transactions: [Transaction]
}

