//
//  UserManagementBar.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 13/01/25.
//

import SwiftUI

struct AuthenticationMenu: View {
    @StateObject private var firestoreService = FirestoreService()
    @State var allUsers: [User] = []
    @State var isVerifiedUser: Bool = false
    @State var isSignUp: Bool = false
    @State var userId: String = ""
    @State var pin: String = ""
    @State var reEnterPin: String = ""
    @State var showErrorAlert: Bool = false
    @State var errorHeading: String = ""
    @State var errorMessage: String = ""
    @State var isPinValid: Bool = false
    @State var isPinMatch: Bool = false
    @State var isReadyToNavigate: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text(isSignUp ? "Sign Up" : "Sign In")
                .font(.title3).bold()
                .foregroundStyle(.orange)
                .padding(.bottom, 5)
            Text(isSignUp ? "Create a unique user ID & PIN to sign up. If you already have an account, please sign in." : "Enter Player ID & PIN of an existing player to sign in. If you don't have an account yet, please sign up.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 10)
            
            if isSignUp {
                HStack {
                    HStack {
                        TextField("Create Player ID", text: $userId)
                            .font(.subheadline)
                            .foregroundStyle(isVerifiedUser ? .gray : .primary)
                            .onChange(of: userId) { oldValue, newValue in
                                userId = newValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                                isVerifiedUser = false
                            }
                        
                        if !userId.isEmpty {
                            Image(systemName: isVerifiedUser ? "checkmark.circle" : "xmark.circle")
                                .foregroundStyle(isVerifiedUser ? .green : .red)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    HStack {
                        TextField("3-10 digit PIN", text: $pin)
                            .font(.subheadline)
                            .foregroundStyle(isVerifiedUser ? .gray : .primary)
                            .onChange(of: pin) { oldValue, newValue in
                                pin = newValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                                isPinValid = false
                            }
                        
                        if !pin.isEmpty {
                            Image(systemName: isPinValid ? "checkmark.circle" : "xmark.circle")
                                .foregroundStyle(isPinValid ? .green : .red)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                
                ZStack {
                    if isVerifiedUser && isPinValid {
                        HStack {
                            TextField("Re enter PIN", text: $reEnterPin)
                                .font(.subheadline)
                                .foregroundStyle(isPinMatch ? .gray : .primary)
                                .onChange(of: reEnterPin) { oldValue, newValue in
                                    reEnterPin = newValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                                    isPinMatch = pin == reEnterPin
                                }
                            
                            if !reEnterPin.isEmpty {
                                Image(systemName: isPinMatch ? "checkmark.circle" : "xmark.circle")
                                    .foregroundStyle(isPinMatch ? .green : .red)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                    } else {
                        Button(action: {
                            isVerifiedUser = isUserIdUnique()
                            isPinValid = isPinFormatValid()
                        }) {
                            Text("Verify")
                                .font(.subheadline)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .alert(errorHeading, isPresented: $showErrorAlert) {
                                    Button("OK", role: .cancel) {}
                                } message: {
                                    Text(errorMessage)
                                }
                        }
                        .foregroundStyle(.orange)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.bottom, 2)
                    }
                }
                .padding(.bottom, 5)
            } else {
                HStack {
                    TextField("Player ID", text: $userId)
                        .font(.subheadline)
                        .foregroundStyle(isVerifiedUser ? .gray : .primary)
                        .onChange(of: userId) { oldValue, newValue in
                            userId = newValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                            isVerifiedUser = false
                        }
                    
                    if !userId.isEmpty {
                        Image(systemName: isVerifiedUser ? "checkmark.circle" : "xmark.circle")
                            .foregroundStyle(isVerifiedUser ? .green : .red)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                
                ZStack {
                    if isVerifiedUser {
                        TextField("PIN", text: $pin)
                            .keyboardType(.numberPad)
                            .font(.subheadline)
                            .foregroundStyle(isVerifiedUser ? .gray : .primary)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onChange(of: pin) { oldValue, newValue in
                                pin = newValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                            }
                    } else {
                        Button(action: {
                            isVerifiedUser = verifyUser()
                        }) {
                            Text("Verify")
                                .font(.subheadline)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .alert(errorHeading, isPresented: $showErrorAlert) {
                                    Button("OK", role: .cancel) {}
                                } message: {
                                    Text(errorMessage)
                                }
                        }
                        .foregroundStyle(.orange)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.bottom, 2)
                    }
                }
                .padding(.bottom, 5)
            }
            
            if !isVerifiedUser || (!isPinValid && isSignUp) {
                Button(action: {
                    isSignUp.toggle()
                    isVerifiedUser = false
                    isPinValid = false
                    pin = ""
                    userId = ""
                }) {
                    Text((!isVerifiedUser && !isSignUp) ?
                         "New here? Sign up to get started"
                         : "Already signed up? Sign in")
                    .font(.subheadline)
                    .fontWeight(.medium)
                }
                .padding(.bottom, 50)
                .padding(.vertical, 5)
            } else {
                Button(action: {
                    if isSignUp {
                        let readyToCreateUser = isVerifiedUser && isPinValid && pin == reEnterPin
                        if readyToCreateUser {
                            firestoreService.createUser(id: userId, pin: pin) { _ in }
                            isReadyToNavigate = true
                        }
                        
                    } else {
                        isPinValid = verifyPin()
                        isReadyToNavigate = isVerifiedUser && isPinValid
                    }
                }) {
                    Text("Sign in")
                        .font(.subheadline)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .alert(errorHeading, isPresented: $showErrorAlert) {
                            Button("OK", role: .cancel) {}
                        } message: {
                            Text(errorMessage)
                        }
                        .navigationDestination(isPresented: $isReadyToNavigate) {
                            HomeView()
                        }
                }
                .foregroundStyle(.orange)
                .padding()
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, 28)
            }
            
        }
        .onAppear {
            firestoreService.fetchUsers { users in
                self.allUsers = users
            }
        }
    }
    
    private func verifyUser() -> Bool {
        let user = allUsers.first(where: { $0.id == userId })
        if user == nil {
            showErrorAlert = true
            errorHeading = "User not found"
            errorMessage = "Try signing up instead"
            return false
        }
        return true
    }
    
    private func isPinFormatValid() -> Bool {
        if pin.isEmpty {
            return false
        }
        else if !(pin.count >= 3 && pin.count <= 10) {
            showErrorAlert = true
            errorHeading = "Invalid PIN"
            errorMessage = "PIN must be between 3 and 10 characters"
            return false
        }
        return true
    }
    
    private func verifyPin() -> Bool {
        let i = allUsers.firstIndex(where: { $0.id == userId })
        let fetchedPin = allUsers[i!].pin
        if fetchedPin != pin {
            showErrorAlert = true
            errorHeading = "Incorrect PIN"
            errorMessage = "Re enter your pin or try signing up"
            return false
        }
        return true
    }
    
    private func isUserIdUnique() -> Bool {
        let user = allUsers.first(where: { $0.id == userId })
        if user != nil {
            showErrorAlert = true
            errorHeading = "User ID already exists"
            errorMessage = "Try using a different ID or sign in instead"
            return false
        }
        return true
    }
}


#Preview {
    AuthenticationMenu()
}
