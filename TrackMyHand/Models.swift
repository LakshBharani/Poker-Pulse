//
//  Models.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 14/12/24.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String
    var totalProfit: Double
    var isFavorite: Bool
    var profitData: [Double]
    var totalWins: Int
    var timePlayed: Double
    var totalBuyIn: Double
}

struct Player: Identifiable, Codable {
    var id: String
    var buyIn: Double
    var cashOut: Double
    var profit: Double
}

struct Game: Identifiable, Codable {
    var isActive: Bool
    var id: String
    var gameCode: String
    var totalPot: Double
    var date: Date
    var players: [Player]
    var transactions: [Transaction]
}

struct Transaction: Identifiable, Codable {
    var id: String
    var time: Date
    var type: String // "buyIn" or "cashOut"
    var userId: String
    var amount: Double
}

struct GameData {
    var code: String
}

