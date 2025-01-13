//
//  FirebaseService.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 14/12/24.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUICore

class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()
    
    func fetchAdSettings(adIdentifier: String, completion: @escaping (AdSettings?) -> Void) {
        let collectionRef = db.collection("adSettings")
        let docRef = collectionRef.document(adIdentifier)
        
        docRef.getDocument { document, error in
            if let error = error {
                print("Error fetching document: \(error)")
                completion(nil)
                return
            }
            guard let document = document, document.exists,
                  let data = document.data() else {
                print("Document does not exist or data is invalid")
                completion(nil)
                return
            }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let adSettings = try JSONDecoder().decode(AdSettings.self, from: jsonData)
                completion(adSettings)
            } catch {
                print("Error decoding AdSettings: \(error)")
                completion(nil)
            }
        }
    }

    
    // create new group
    func createGroup(userId: String, name: String, completion: @escaping ([User]) -> Void) {
        do {
            let collectionRef = db.collection("groups")
            let groupRef = collectionRef.document()
            self.fetchUsers { users in
                if !users.contains(where: { $0.id == userId }) {
                    self.createUser(id: userId) { _ in }
                }
            }
            let group = Group(id: groupRef.documentID, name: name, inviteCode: "", users: [userId])
            let _ = try db.collection("groups").document(group.id).setData(from: group)
            
        } catch _ {}
        
    }

    // Fetch all users
    func fetchUsers(completion: @escaping ([User]) -> Void) {
        db.collection("users")
            .order(by: "totalProfit", descending: true)
            .getDocuments { (snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("Error fetching users: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                let users = documents.compactMap { try? $0.data(as: User.self) }
                completion(users)
            }
        
    }
    
    // fetch total number of users
    func fetchTotalUserCount(completion: @escaping (Int?) -> Void) {
        db.collection("users").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error fetching game count: \(err.localizedDescription)")
                completion(nil)
            } else {
                let count = querySnapshot?.documents.count ?? 0
                completion(count)
            }
        }
    }
    
    // create a user for the first time using id
    func createUser(id: String, pin: String = "", completion: @escaping (Result<User, Error>) -> Void) {
        do {
            let user = User(id: id, pin: pin, totalProfit: 0, isFavorite: false, profitData: [0], totalWins: 0, timePlayed: 0, totalBuyIn: 0)
            let _ = try db.collection("users").document(user.id).setData(from: user)
            
        } catch _ {}
    }
    
    // Fetch only top 3 users with most profit
    func fetchLeaderboard(completion: @escaping ([User]) -> Void) {
        db.collection("users")
            .order(by: "totalProfit", descending: true)
            .limit(to: 3)
            .getDocuments { (snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("Error fetching users: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                let users = documents.compactMap { try? $0.data(as: User.self) }
                completion(users)
            }
    }
    
    // Fetch all games
    func fetchGames(limit: Int, completion: @escaping ([Game]) -> Void) {
        db.collection("games")
            .order(by: "date", descending: true)
            .limit(to: limit)
            .getDocuments { (snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("Error fetching games: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                let games = documents.compactMap { try? $0.data(as: Game.self) }
                completion(games)
            }
    }
    
    // fetch total number of games
    func fetchTotalGameCount(completion: @escaping (Int?) -> Void) {
        db.collection("games").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error fetching game count: \(err.localizedDescription)")
                completion(nil)
            } else {
                let count = querySnapshot?.documents.count ?? 0
                completion(count)
            }
        }
    }

    
    // Add a new game
    // Function to add a new game
    func createGame(game: Game, completion: @escaping (Error?) -> Void) {
        do {
            let _ = try db.collection("games").document(game.id).setData(from: game)
            // Update each user's stats
            for player in game.players {
                updateUserStatsOnGameStart(userId: player.id, profit: player.profit) { _ in }
            }
            completion(nil)
        } catch let error {
            completion(error)
        }
    }
    
    // Update user stats before a game -> to prepare db to handle transaction changes
    func updateUserStatsOnGameStart(userId: String, profit: Double, completion: @escaping (Error?) -> Void) {
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                completion(error)
                return
            }
            
            if let document = document, !document.exists {
                print("Creating new user...")
                self.createUser(id: userId) { _ in }
            }
        }
    }
    
    // update game on event log
    func updateGameOnEvent(game: Game, completion: @escaping (Error?) -> Void) {
        let gameRef = db.collection("games").document(game.id)
        
        gameRef.getDocument { (document, error) in
            if let error = error {
                completion(error)
                return
            }
            
            if let document = document, document.exists {
                do {
                    try gameRef.setData(from: game)
                    completion(nil)
                } catch let error {
                    completion(error)
                }
            } else {
                completion(NSError(domain: "DocumentNotFound", code: 404, userInfo: nil))
            }
        }
    }
    
    // update ingame clock in db
    func updateIngameClock(game: Game, completion: @escaping (Error?) -> Void) {
        let gameRef = db.collection("games").document(game.id)
        
        gameRef.getDocument { (document, error) in
            if let error = error {
                completion(error)
                return
            }
            
            if let document = document, document.exists {
                gameRef.updateData([
                    "timeElapsed": game.timeElapsed
                ]) { error in
                    completion(error)
                }
            }
        }
    }
    
    func updateGameStatusOnEnd(game: Game, completion: @escaping (Error?) -> Void) {
        let gameRef = db.collection("games").document(game.id)
        
        if game.timeElapsed == [0, 0, 0] {
            gameRef.delete { error in
                completion(error)
            }
            return
        }
        
        gameRef.getDocument { (document, error) in
            if let error = error {
                completion(error)
                return
            }
            
            if let document = document, document.exists {
                gameRef.updateData([
                    "isActive": false
                ]) { error in
                    completion(error)
                }
            }
        }
    }
    
    func updateUserStatsOnGameEnd(game: Game, completion: @escaping (Error?) -> Void) async {
        let usersRef = db.collection("users")
        let timePlayed = Double(game.timeElapsed[0] * 60 + game.timeElapsed[1] + (game.timeElapsed[2] > 30 ? 1 : 0))
        
        for player in game.players {
            do {
                let userData = try await usersRef.document(player.id).getDocument(as: User.self)
                try await usersRef.document(player.id).updateData([
                    "totalBuyIn": FieldValue.increment(player.buyIn),
                    "totalProfit": FieldValue.increment(player.profit),
                    "profitData": userData.profitData + [userData.profitData.last! + player.profit],
                    "timePlayed": FieldValue.increment(timePlayed),
                    "totalWins": FieldValue.increment(player.profit > 0 ? 1 : 0.0)
                ])
                
            } catch {
                completion(error)
                return
            }
        }
        completion(nil)
    }
    
    func toggleFavorite(userID: String, completion: @escaping (Error?) -> Void) {
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { document, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let document = document, document.exists,
                  let currentFavorite = document.data()?["isFavorite"] as? Bool else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found or invalid data"]))
                return
            }
            
            userRef.updateData(["isFavorite": !currentFavorite]) { error in
                completion(error)
            }
        }
    }
    
}
