//
//  Models.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 14/12/24.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String
    var pin: String?
    var totalProfit: Double
    var isFavorite: Bool
    var profitData: [Double]
    var totalWins: Int
    var timePlayed: Int
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
    var isGameEnded: Bool
    var id: String
    var timeElapsed: [Int]
    var gameCode: String
    var totalPot: Double
    var cashOut: Double
    var date: Date
    var players: [Player]
    var events: [Transaction]
}

struct Transaction: Identifiable, Codable {
    var id: Int
    var time: Date = Date()
    var description: String
    var from: String
    var to: String
    var amount: String
}

struct Group: Identifiable, Codable {
    var id: String
    var name: String
    var inviteCode: String
    var users: [String]
}

struct AdSettings: Codable {
    var adEnabled: Bool
    var height: Double
    var id: String
}

