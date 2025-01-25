//
//  AuthView.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 13/01/25.
//

import SwiftUI

struct AuthView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.orange.opacity(0.25), .black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    AuthenticationMenu()
                        .padding()
                    Spacer()
                }.navigationTitle(Text("Poker Tracker"))
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    AuthView()
}
