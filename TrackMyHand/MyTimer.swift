//
//  MyTimer.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 07/01/25.
//

import Foundation

class MyTimer: ObservableObject {
    @Published var hoursElapsed = 0
    @Published var minutesElapsed = 0
    @Published var secondsElapsed = 0

    private var timer: Timer?
    private var startDate: Date?

    func start(firestoreService: FirestoreService, game: Game) {
        self.startDate = game.date
        
        // Schedule the timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, let startDate = self.startDate else { return }
            
            let currentTime = Date()
            let elapsedTime = currentTime.timeIntervalSince(startDate)
            
            self.hoursElapsed = Int(elapsedTime) / 3600
            self.minutesElapsed = (Int(elapsedTime) % 3600) / 60
            self.secondsElapsed = Int(elapsedTime) % 60
            
            var updatedGame = game
            updatedGame.timeElapsed = [self.hoursElapsed, self.minutesElapsed, self.secondsElapsed]
            
            firestoreService.updateIngameClock(game: updatedGame) { _ in }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
