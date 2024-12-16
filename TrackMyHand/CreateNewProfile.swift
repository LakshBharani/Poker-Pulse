//
//  CreateNewProfile.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 16/12/24.
//

import SwiftUI

struct CreateNewProfile: View {
    @StateObject private var firestoreService = FirestoreService()
    @State private var allUsers: [User] = []
    @State private var isDisabled = true
    @State var id: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("First Name")) {
                    TextField("LAKSH", text: $id)
                        .autocapitalization(.allCharacters)
                        .autocorrectionDisabled(true)
                        .keyboardType(.alphabet)
                        .onChange(of: id) { oldValue, newValue in
                            if !allUsers.contains(where: { $0.id == newValue }) {
                                isDisabled = false
                            } else {
                                isDisabled = true
                            }
                        }
                }
                
                Button(action: {
                    firestoreService.createUser(id: id, completion: {_ in 
                        print("user created")
                    })
                }) {
                    Text("Create Profile")
                }
                .disabled(id.isEmpty || id.count < 3 || isDisabled)
            }
        }
        .navigationTitle("Create Profile")
        .onAppear() {
            firestoreService.fetchUsers { users in
                self.allUsers = users
            }
        }
    }
}

#Preview {
    CreateNewProfile()
}
