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
    @State var period: Int = 1

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
        let averageBuyIn = String(format: "%.2f", user.totalBuyIn / Double(user.profitData.count - 1))
        let screenGradient = user.totalProfit >= 0 ? [Color.green.opacity(0.25), Color.black] : [Color.red.opacity(0.25), Color.black]
        
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Activity Summary")
                            .foregroundColor(.white).opacity(0.7)
                            .font(.title2)
                            .bold()
                            .padding(.bottom)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if (user.profitData.count > 1) {
                        // widget showing profit over time
                        chartWidget()
                            .onAppear() {
                                if user.profitData.count < 4 {
                                    period = 1
                                } else if user.profitData.count < 10 {
                                    period = 5
                                } else {
                                    period = user.profitData.count < 4 ? 1 : Int(user.profitData.count / 5)
                                }
                                
                            }
                        
                        
                        HStack {
                            Text("All Time ($)")
                                .font(.system(size: 16))
                                .foregroundColor(.white).opacity(0.7)
                            Divider()
                                .padding(.horizontal)
                            Spacer()
                            HStack {
                                Text("\(user.totalProfit >= 0 ? "+" : "-") \(abs(user.totalProfit), specifier: "%.2f")")
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(getProfitColor(profit: user.totalProfit))
                                
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 13).fill(Color.gray.opacity(0.2)))
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 10) {
                            createInfoBox(title: "Sessions", value: sessions)
                            createReactiveInfoBox(title: "\(user.totalProfit >= 0 ? "Profit" : "Loss") / Session", value: profit_per_session)
                            createInfoBox(title: "Minutes Played", value: timePlayed)
                            createReactiveInfoBox(title: "\(user.totalProfit >= 0 ? "Profit" : "Loss") / Minute", value: profit_per_min)
                            createInfoBox(title: "Win Rate (%)", value: "\(winRate)%")
                            createInfoBox(title: "Avg. BuyIn", value: averageBuyIn)
                        }
                        .padding(.horizontal)
                        
                    } else {
                        errorbanner()
                    }
                }
                .padding(.vertical)
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
    
    
    // Simple Moving Average function
    func simpleMovingAverage(data: [Double], period: Int) -> [Double] {
        var smaValues = [Double]()
        
        for i in 0..<data.count {
            if i >= period - 1 {
                let window = data[(i - period + 1)...i]
                let sma = window.reduce(0, +) / Double(period)
                smaValues.append(sma)
            } else {
                smaValues.append(0)
            }
        }
        
        return smaValues
    }
    
    func generateProfits(from netProfits: [Double]) -> [Double] {
        var profits: [Double] = []
        
        for i in 1..<netProfits.count {
            let profit = netProfits[i] - netProfits[i - 1]
            profits.append(profit)
        }
        
        return profits
    }
    
    func chartWidget() -> some View {
        let profitData = user.profitData
        let smaValues = simpleMovingAverage(data: profitData, period: period)
        
        return VStack {
            Chart {
                // Plot main line and area chart
                ForEach(0..<user.profitData.count, id: \.self) { session in
                    AreaMark(
                        x: PlottableValue.value("Session 1", session),
                        y: PlottableValue.value("Net Profit", user.profitData[session])
                    )
                    .foregroundStyle(getCurveGradient(profit: user.totalProfit))
                    
                    LineMark(
                        x: PlottableValue.value("Session 1", session),
                        y: PlottableValue.value("Net Profit", user.profitData[session]),
                        series: .value("Line", "One")
                    )
                    .foregroundStyle(getProfitColor(profit: user.totalProfit))
                    
                    PointMark(
                        x: PlottableValue.value("Session 1", session),
                        y: PlottableValue.value("Net Profit", user.profitData[session]))
                    .foregroundStyle(getProfitColor(profit: user.totalProfit))
                    .symbolSize(20)
                    
                    LineMark(
                        x: PlottableValue.value("Session 2", session),
                        y: PlottableValue.value("Median", smaValues[session]),
                        series: .value("Line", "Two")
                    )
                    .foregroundStyle(.white).opacity(0.7)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                }
                
                RuleMark(y: .value("Break-Even", 0))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [1]))
                    .foregroundStyle(.gray)
                
                
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    // Track user interaction
                    TouchInteractionView(
                        proxy: proxy,
                        geometry: geometry,
                        user: user,
                        plotAreaFrame: CGRect()
                    )
                }
            }
            .chartXAxisLabel(position: .bottom, alignment: .center) {
                Text("Session Number")
                    .foregroundColor(.white).opacity(0.7)
            }
            .chartYAxisLabel(position: .leading, alignment: .center) {
                Text("Net Profit")
                    .foregroundColor(.white).opacity(0.7)
            }
            .chartLegend(position: .top, alignment: .leading)
            .chartXScale(domain: 0...(user.profitData.count - 1))
            .padding(.bottom)
            .padding(.horizontal)
            .frame(height: 300)
        }
    }


    struct TouchInteractionView: View {
        let proxy: ChartProxy
        let geometry: GeometryProxy
        let user: User
        let plotAreaFrame: CGRect

        @State private var hoveredXValue: Int?
        @State private var hoveredYValue: Double?
        @State private var isTouching: Bool = false

        var body: some View {
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle()) // Enable interaction
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isTouching = true
                            
                            // Get X-axis value based on touch location
                            if let xValue: Int = proxy.value(atX: value.location.x) {
                                hoveredXValue = xValue
                                
                                // Get corresponding Y-axis value
                                if xValue >= 0 && xValue < user.profitData.count {
                                    hoveredYValue = user.profitData[xValue]
                                }
                            }
                        }
                        .onEnded { _ in
                            isTouching = false
                            hoveredXValue = nil
                            hoveredYValue = nil
                        }
                )
                .overlay {
                    if let xValue = hoveredXValue, let yValue = hoveredYValue, isTouching {
                        let resolvedFrame = geometry[proxy.plotFrame!]

                        VStack(spacing: 5) {
                            Text("Session: \(xValue)")
                                .font(.caption)
                                .foregroundColor(.white)
                            Text("Net Profit: \(yValue, specifier: "%.2f")")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(5)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                        .position(
                            x: resolvedFrame.minX + proxy.position(forX: xValue)!,
                            y: resolvedFrame.minY + proxy.position(forY: yValue)!
                        )
                    }
                }
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
    
    func getProfitColor(profit: Double) -> Color {
        if (profit >= 0) {
            return Color.green
        } else {
            return Color.red
        }
    }
    
    func getCurveGradient(profit: Double) -> LinearGradient {
        let profitColor = Color(hue: 0.33, saturation: 0.81, brightness: 0.76)
        let lossColor = Color(hue: 0, saturation: 0.81, brightness: 0.76)
        
        if (profit >= 0) {
            return LinearGradient(
                gradient: Gradient (
                    colors: [
                        profitColor.opacity(0.5),
                        profitColor.opacity(0.2),
                        profitColor.opacity(0.1),
                        profitColor.opacity(0.03),
                    ]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            return LinearGradient(
                gradient: Gradient (
                    colors: [
                        lossColor.opacity(0.5),
                        lossColor.opacity(0.2),
                        lossColor.opacity(0.1),
                        lossColor.opacity(0.03),
                    ]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    func createInfoBox(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white).opacity(0.7)
            Divider()
            Text(value.replacingOccurrences(of: "-", with: ""))
                .font(.system(size: 30))
                .bold()
                .foregroundStyle(.mint)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 13).fill(Color.gray.opacity(0.2)))
    }
    
    func createReactiveInfoBox(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white).opacity(0.7)
            Divider()
            if (Double(value)! > 0) {
                Text(value)
                    .font(.system(size: 30))
                    .bold()
                    .foregroundStyle(.green)
            } else if (Double(value)! < 0) {
                Text(value.replacingOccurrences(of: "-", with: ""))
                    .font(.system(size: 30))
                    .bold()
                    .foregroundStyle(.red)
            } else {
                Text(value)
                    .font(.system(size: 30))
                    .bold()
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 13).fill(Color.gray.opacity(0.2)))
    }
}


#Preview {
    UserDetails(user: User(id: "LAKSH", totalProfit: -120, isFavorite: false, profitData: [0, -120], totalWins: 0, timePlayed: 10, totalBuyIn: 10))
}
