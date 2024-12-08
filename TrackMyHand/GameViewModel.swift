//
//  GameViewModel.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 21/11/24.
//

import Firebase
import Combine
import FirebaseDatabaseInternal

class GameViewModel: ObservableObject {
    @Published var games: [Game] = []
    private var db = Database.database().reference()
    
    func fetchGames() {
        db.child("games").observe(.value) { snapshot in
            var fetchedGames: [Game] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let value = snapshot.value as? [String: Any],
                   let jsonData = try? JSONSerialization.data(withJSONObject: value),
                   let game = try? JSONDecoder().decode(Game.self, from: jsonData) {
                    fetchedGames.append(game)
                }
            }
            DispatchQueue.main.async {
                self.games = fetchedGames
            }
        }
    }
}
