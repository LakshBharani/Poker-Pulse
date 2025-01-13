//
//  AllUsers.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 15/12/24.
//

import SwiftUI

struct AllUsers: View {
    @StateObject private var firestoreService = FirestoreService()
    @State private var searchText: String = ""
    @State private var users: [User] = []
    
    var visibleUsers: [User] {
            if searchText.isEmpty {
                return users
            } else {
                return users.filter { $0.id.localizedCaseInsensitiveContains(searchText) }
            }
        }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.green.opacity(0.25), .black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if users.isEmpty {
                        LoadingView(subTitle: "Fetching users...")
                    }
                    else {
                        List {
                            ForEach(visibleUsers) { user in
                                HStack {
                                    NavigationLink(destination: UserDetails(user: user)) {
                                        HStack {
                                            Text("\(user.id)")
                                                .font(.subheadline)
                                                .foregroundStyle(.orange)
                                                .bold()
                                            Spacer()
                                            Text("\(user.totalProfit >= 0 ? "+" : "-") \(abs(user.totalProfit), specifier: "%.2f")")
                                                .font(.system(size: 14))
                                                .bold()
                                                .foregroundStyle(user.totalProfit >= 0 ? .green : .red)
                                                .padding(EdgeInsets.init(top: 1, leading: 5, bottom: 1, trailing: 5))
                                                .background(content: {
                                                    RoundedRectangle(cornerRadius: CGFloat(5))
                                                        .foregroundStyle(user.totalProfit >= 0 ? .green.opacity(0.2) : .red.opacity(0.2))
                                                })
                                        }
                                        .padding(.trailing, 10)
                                    }
                                }
                            }
                        }
                        .searchable(text: $searchText)
                        .scrollContentBackground(.hidden)
                    }
                    PlacableAdBanner(adIdentifier: "banner0")
                }
            }
        }
        .navigationTitle("All Users")   
        .onAppear() {
            firestoreService.fetchUsers { users in
                self.users = users
            }
        }
    }
}

#Preview {
    AllUsers()
}
