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
            VStack {
                if users.isEmpty {
                    LoadingView(subTitle: "Fetching users...")
                }
                else {
                    List {
                        ForEach(visibleUsers) { user in
                            HStack {
                                NavigationLink(destination: UserDetails(user: user)) {
                                    Text("\(user.id)")
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText)
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
