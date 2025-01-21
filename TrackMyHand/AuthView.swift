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

                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        
                        Image("my-logo-transparent")
                            .resizable()
                            .scaledToFit()
                            .padding(25)
                            .frame(width: 150) // Fixed width
                            .background(Color.black.opacity(0.25))
                            .clipShape(Circle())
                            .shadow(radius: 10)
                        
                        Spacer()
                            .frame(height: geometry.size.height * 0.1)
                        
                        AuthenticationMenu()
                        
                        Spacer()
                    }
                    .padding()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea(.keyboard)
                    
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    AuthView()
}
