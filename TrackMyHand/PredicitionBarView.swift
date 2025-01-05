//
//  PredicitionBarView.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 05/01/25.
//

import SwiftUI
import CoreML

struct PredictionBarView: View {
    @ObservedObject var gameViewModel: GameViewModel

    var body: some View {
        HStack {
            Text("Predictions")
                .font(.subheadline)
                .padding(.horizontal)
                .bold()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(gameViewModel.game.players.indices, id: \.self) { i in
                        if i != 0 {
                            HStack(alignment: .center) {
                                Text(gameViewModel.game.players[i].id)
                                    .font(.subheadline)
                                Text(String(format: "%.2f", gameViewModel.predictions[i]))
                                    .font(.subheadline)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(gameViewModel.predictions[i] > 0 ? .green.opacity(0.3) : .red.opacity(0.3))
                                    .cornerRadius(5)
                                    .foregroundColor(gameViewModel.predictions[i] > 0 ? Color.green : Color.red)
                                Divider()
                            }
                            .padding(.horizontal, 5)
                        }
                    }
                }
                .padding()
                .background(.black)
            }
        }
        .background(.gray.opacity(0.2))
        .cornerRadius(10)
        .padding(.top, 1)
        .onAppear {
            gameViewModel.recalculatePredictions()
        }
    }
}

class GameViewModel: ObservableObject {
    @Published var game: Game
    @Published var predictions: [Double] = []

    init(game: Game) {
        self.game = game
        recalculatePredictions()
    }

    func recalculatePredictions() {
        let buyIns = game.players.map { $0.buyIn }
        let profits = game.players.map { $0.cashOut }
        predictions = makePredictions(buyIn: buyIns, currProfit: profits)
    }

    private func makePredictions(buyIn: [Double], currProfit: [Double]) -> [Double] {
        let model = try? ProfitPredictorModel(configuration: MLModelConfiguration())
        var predictions: [Double] = []
        for i in 0..<currProfit.count {
            let input = ProfitPredictorModelInput(Buy_in: Int64(buyIn[i]), CurrentProfit: currProfit[i])
            do {
                let prediction = try model!.prediction(input: input)
                predictions.append(prediction.FinalProfit)
            } catch {
                print("Error making prediction: \(error)")
            }
        }
        return predictions
    }
}

#Preview {
    let game = Game(isActive: true, id: "7B97E339-3EEF-4431-B6A7-85681B64D002", timeElapsed: [0, 0, 0], gameCode: "7B9002", totalPot: 40.0, cashOut: 0, date: Date(), players: [TrackMyHand.Player(id: "LAKSH", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "ATHARV", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "SAHAJ", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "USMAAN", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "AREEB", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "SAIF", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "ANIRUDH", buyIn: 5.0, cashOut: 0.0, profit: -5.0), TrackMyHand.Player(id: "LAKSHYA", buyIn: 5.0, cashOut: 0.0, profit: -5.0)], events: [])
    PredictionBarView(gameViewModel: GameViewModel(game: game))
}
