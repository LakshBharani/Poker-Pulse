//
//  JoinGroupView.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 07/01/25.
//

import SwiftUI

struct JoinGroupView: View {
    @State var groupID: String = ""
    
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
                    Image(.joinGroup0)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300)
                        .padding()
                        .padding(.bottom, 30)
                    
                    Text("Insert description here")
                    
                    HStack {
                        TextField("Enter Group ID", text: $groupID)
                            .autocorrectionDisabled(true)
                            .lineLimit(1)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black))
                        
                        Button(action: {
                            print("Joining")
                        }) {
                            Text("Join Group")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(Color.orange)
                                .cornerRadius(10)
                                .font(.headline)
                        }

                    }
                    
                    Button(action: {
                        print("Joining")
                    }) {
                        Text("Create Group")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(Color.orange)
                            .cornerRadius(10)
                            .font(.headline)
                    }


                    
                }
                .padding(.horizontal)
            }
        }
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    JoinGroupView()
}
