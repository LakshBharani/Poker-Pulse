//
//  ChartView.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 07/01/25.
//

import SwiftUI
import Charts

struct ChartWidget: View {
    var user: User
    let profitColor = Color(hue: 0.33, saturation: 0.81, brightness: 0.76)
    let lossColor = Color(hue: 0, saturation: 0.81, brightness: 0.76)
    
    @State var currPlot = ""
    @State var offset: CGSize = .zero
    @State var showPlot = false
    @State var translation: CGFloat = 0
    @State var period: Int = 1
    
    @State private var showWeightedAvg: Bool = true
    
    var body: some View {
        VStack(alignment: .leading) {
            let profitData = user.profitData
            let smaValues = simpleMovingAverage(data: profitData, period: period)
            
            HStack {
                Rectangle()
                    .fill(user.totalProfit >= 0 ? .green : .red)
                    .frame(height: 1.5)
                    .edgesIgnoringSafeArea(.horizontal)
                    .frame(width: 15)
                Text("Net Profit").font(.system(size: 10))
                    .foregroundStyle(.white).opacity(0.7)
                Circle().fill(user.totalProfit >= 0 ? .green : .red)
                    .frame(width: 15, height: 5)
                Text("Profit Data").font(.system(size: 10))
                    .foregroundStyle(.white).opacity(0.7)
                HLine().stroke(style: StrokeStyle(lineWidth: 1, dash: [3]))
                    .frame(width: 15, height: 1)
                    .foregroundStyle(.white).opacity(0.6)
                Text("Predicted Profit").font(.system(size: 10))
                    .foregroundStyle(.white).opacity(0.7)
                    .lineLimit(1)
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            
            Chart {
                // Plot main line and area chart
                ForEach(0..<user.profitData.count, id: \.self) { session in
                    AreaMark(
                        x: PlottableValue.value("Session", session),
                        y: PlottableValue.value("Net Profit", user.profitData[session])
                    )
                    .foregroundStyle(getCurveGradient(profit: user.totalProfit))
                    
                    LineMark(
                        x: PlottableValue.value("Session", session),
                        y: PlottableValue.value("Median", smaValues[session]),
                        series: .value("Line", "weightedAvg")
                    )
                    .foregroundStyle(.white).opacity(0.6)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [3]))
                    
                    LineMark(
                        x: PlottableValue.value("Session", session),
                        y: PlottableValue.value("Net Profit", user.profitData[session]),
                        series: .value("Line", "main")
                    )
                    .foregroundStyle(getProfitColor(profit: user.totalProfit))
                    
                    PointMark(
                        x: PlottableValue.value("Session", session),
                        y: PlottableValue.value("Net Profit", user.profitData[session])
                    )
                    .foregroundStyle(getProfitColor(profit: user.totalProfit))
                    .symbolSize(20)
                }
                
                RuleMark(y: .value("Break-Even", 0))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [1]))
                    .foregroundStyle(.gray)
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    TouchInteractionView(
                        proxy: proxy,
                        geometry: geometry,
                        user: user
                    )
                }
            }
            .chartXAxisLabel(position: .bottom, alignment: .center) {
                Text("Session Number")
                    .foregroundColor(.white).opacity(0.5)
            }
            .chartYAxisLabel(position: .leading, alignment: .center) {
                Text("Net Profit")
                    .foregroundColor(.white).opacity(0.5)
            }
            .chartLegend(position: .top, alignment: .leading)
            .chartXScale(domain: 0...(user.profitData.count - 1))
            .padding(.bottom)
            .padding(.horizontal)
        }
        
        .onAppear() {
            if user.profitData.count < 4 {
                period = 1
            } else if user.profitData.count < 10 {
                period = 5
            } else {
                period = user.profitData.count < 4 ? 1 : Int(user.profitData.count / 5)
            }
            
        }
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
    

    func getProfitColor(profit: Double) -> Color {
        if (profit >= 0) {
            return Color.green
        } else {
            return Color.red
        }
    }
    
    func getCurveGradient(profit: Double) -> Gradient {
        let profitColor = Color(hue: 0.33, saturation: 0.81, brightness: 0.76)
        let lossColor = Color(hue: 0, saturation: 0.81, brightness: 0.76)
        
        if (profit >= 0) {
            return Gradient (
                    colors: [
                        profitColor.opacity(0.5),
                        profitColor.opacity(0.2),
                        profitColor.opacity(0.1),
                        profitColor.opacity(0.03),
                    ]
                )
            
        } else {
            return Gradient (
                    colors: [
                        lossColor.opacity(0.5),
                        lossColor.opacity(0.2),
                        lossColor.opacity(0.1),
                        lossColor.opacity(0.03),
                    ]
                )
        }
    }
    
}

struct TouchInteractionView: View {
    let proxy: ChartProxy
    let geometry: GeometryProxy
    let user: User

    @State private var hoveredXValue: Int?
    @State private var hoveredYValue: Double?
    @State private var isTouching: Bool = false
    @State private var offset: CGSize = .zero

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

                                // Calculate offset for hover tooltip
                                if let xPosition = proxy.position(forX: xValue),
                                   let yPosition = proxy.position(forY: user.profitData[xValue]) {
                                    offset = CGSize(width: xPosition - geometry.size.width / 2 + 21.5,
                                                    height: yPosition - geometry.size.height / 2 - 15)
                                }
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
                if let yValue = hoveredYValue, isTouching {
                    VStack(spacing: 0) {
                        Text("$\(yValue, specifier: "%.2f")")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(yValue >= 0 ? .green.opacity(0.8) : .red.opacity(0.8), in: Capsule())
                        
                        Rectangle()
                            .fill(yValue >= 0 ? .green : .red)
                            .frame(width: 1, height: 25)
                            .padding(.top, 10)
                        
                        Circle()
                            .fill(yValue >= 0 ? .green : .red)
                            .frame(width: 18, height: 18)
                            .overlay(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 7, height: 7)
                            )
                        
                        Rectangle()
                            .fill(yValue >= 0 ? .green : .red)
                            .frame(width: 1, height: 30)
                    }
                    .offset(offset)
                }
            }
    }
}

#Preview {
    ChartWidget(user: User(id: "LAKSH", totalProfit: -50, isFavorite: false, profitData: [0, 5, 10, 7.25, 5, -10, -30, -50], totalWins: 2, timePlayed: 600, totalBuyIn: 50))
}
