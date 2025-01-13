//
//  UserDetails.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 15/12/24.
//

import SwiftUI
import Charts
import CoreML
import Foundation

struct UserDetails: View {
    @State private var cumulativeYData: [Double] = []

    var user: User
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        let sessions = String(user.profitData.count - 1)
        let profit_per_session = String(format: "%.2f", user.totalProfit / Double(user.profitData.count - 1))
        let profit_per_min = String(format: "%.2f", user.totalProfit / Double(user.timePlayed))
        let winRate = String(format: "%.0f", Double(user.totalWins) / Double(user.profitData.count - 1) * 100)
        let timePlayed = String(user.timePlayed)
        let maxProfit = String(format: "%.2f", user.profitData.max()!)
        let maxLoss = String(format: "%.2f", user.profitData.min()!)
        let averageBuyIn = String(format: "%.2f", user.totalBuyIn / Double(user.profitData.count - 1))
        let screenGradient = user.totalProfit >= 0 ? [Color.green.opacity(0.25), Color.black] : [Color.red.opacity(0.25), Color.black]
        
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Activity Summary")
                            .foregroundColor(.white).opacity(0.6)
                            .font(.title2)
                            .bold()
                            .padding(.bottom)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if (user.profitData.count > 1 && user.timePlayed > 0) {
                        // widget showing profit over time
                        
                        ChartWidget(user: user)
                            .frame(height: 375)
                            
                        HStack {
                            createSubtitleInfoBox(title: "Win Rate (%)", value0: "\(winRate)%", subtitle1: "W", subtitle2: "L", value1: String(user.totalWins), value2: String(user.profitData.count - user.totalWins - 1), isReactive: false)
                            createSubtitleInfoBox(title: "All Time ($)", value0: String(user.totalProfit), subtitle1: "Hi", subtitle2: "Lo", value1: String(maxProfit), value2: String(maxLoss), isReactive: true)
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 10) {
                            createInfoBox(title: "Sessions", value: sessions)
                            createReactiveInfoBox(title: "\(user.totalProfit >= 0 ? "Profit" : "Loss") / Session", value: profit_per_session)
                            createInfoBox(title: "Minutes Played", value: timePlayed)
                            createReactiveInfoBox(title: "\(user.totalProfit >= 0 ? "Profit" : "Loss") / Minute", value: profit_per_min)
                            createInfoBox(title: "Avg. BuyIn", value: averageBuyIn)
                        }
                        .padding(.horizontal)
                        
                    } else {
                        errorbanner()
                    }
                }
                .padding(.bottom)
                .padding(.top, 5)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: screenGradient),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
            .navigationTitle("\(user.id)")
        }
        .scrollIndicators(.hidden)
    }
    
    
    func generateProfits(from netProfits: [Double]) -> [Double] {
        var profits: [Double] = []
        
        for i in 1..<netProfits.count {
            let profit = netProfits[i] - netProfits[i - 1]
            profits.append(profit)
        }
        
        return profits
    }


    func getProfitColor(profit: Double) -> Color {
        if (profit >= 0) {
            return Color.green
        } else {
            return Color.red
        }
    }
    
    func errorbanner() -> some View {
        return HStack {
            Image(systemName: "exclamationmark.triangle.fill")
            Text("Play more games to see stats")
                .bold()
            Spacer()
        }
        .foregroundStyle(Color.gray)
        .padding()
        .background(RoundedRectangle(cornerRadius: 13).fill(Color.gray.opacity(0.2)))
            .padding(.horizontal)
    }
    
    func createSubtitleInfoBox(title: String, value0: String, subtitle1: String, subtitle2: String, value1: String, value2: String, isReactive: Bool) -> some View {
        
        
        return VStack(alignment: .leading, spacing: 10) {
            let valueColor = Double(value0) ?? 0 >= 0 ? Color.green : Color.red
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white).opacity(0.5)
            Divider()
            HStack {
                Text("\(value0)".replacingOccurrences(of: "-", with: ""))
                    .font(.system(size: 30))
                    .bold()
                    .foregroundStyle(isReactive ? valueColor : .mint)
                
                Spacer()
            }
            
            HStack {
                Text("\(subtitle1)")
                    .font(.system(size: 14))
                    .foregroundStyle(.green)
                Spacer()
                Text("\(value1)")
                    .font(.system(size: 18))
                    .foregroundStyle(.green)
                    .bold()
            }
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background(RoundedRectangle(cornerRadius: 5).fill(Color.green.opacity(0.2)))
            
            HStack {
                Text("\(subtitle2)")
                    .font(.system(size: 14))
                    .foregroundStyle(.red)
                Spacer()
                Text("\(value2)")
                    .font(.system(size: 18))
                    .foregroundStyle(.red)
                    .bold()
            }
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background(RoundedRectangle(cornerRadius: 5).fill(Color.red.opacity(0.2)))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 13).fill(Color.gray.opacity(0.1)))

    }

    func createInfoBox(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white).opacity(0.5)
            Divider()
            Text(value.replacingOccurrences(of: "-", with: ""))
                .font(.system(size: 30))
                .bold()
                .foregroundStyle(.mint)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 13).fill(Color.gray.opacity(0.1)))
    }
    
    func createReactiveInfoBox(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white).opacity(0.5)
            Divider()
            Text(value.replacingOccurrences(of: "-", with: ""))
                .font(.system(size: 30))
                .bold()
                .foregroundStyle(Double(value)! >= 0 ? .green : .red)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 13).fill(Color.gray.opacity(0.1)))
    }
}

struct HLine: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
    }
}


#Preview {
    UserDetails(user: User(id: "LAKSH", totalProfit: -50, isFavorite: false, profitData: [0, 5, 10, 7.25, 5, -10, -30, -50], totalWins: 2, timePlayed: 600, totalBuyIn: 50))
}
