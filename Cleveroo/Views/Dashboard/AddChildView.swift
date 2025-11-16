//
//  AddChildView.swift
//  Cleveroo
//
//  View for adding a new child
//

import SwiftUI

struct AddChildView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var username = ""
    @State private var age = ""
    @State private var gender: Gender = .male
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var childAddedSuccessfully = false
    
    enum Gender: String, CaseIterable {
        case male = "male"
        case female = "female"
        
        var displayName: String {
            switch self {
            case .male:
                return "Boy"
            case .female:
                return "Girl"
            }
        }
        
        var emoji: String {
            switch self {
            case .male:
                return "👦"
            case .female:
                return "👧"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "9C27B0").opacity(0.9),
                    Color(hex: "98FF98").opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Title
                    Text("Add New Child")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    Text("Create a profile for your child")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.bottom, 20)
                    
                    // Form
                    VStack(spacing: 20) {
                        // Username Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .foregroundColor(.white)
                                .font(.subheadline)
                            
                            TextField("Enter child's username", text: $username)
                                .textFieldStyle(CustomTextFieldStyle())
                                .autocapitalization(.none)
                        }
                        
                        // Age Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Age")
                                .foregroundColor(.white)
                                .font(.subheadline)
                            
                            TextField("Enter child's age", text: $age)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        
                        // Gender Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Gender")
                                .foregroundColor(.white)
                                .font(.subheadline)
                            
                            HStack(spacing: 15) {
                                ForEach(Gender.allCases, id: \.self) { genderOption in
                                    Button(action: {
                                        gender = genderOption
                                    }) {
                                        VStack(spacing: 8) {
                                            Text(genderOption.emoji)
                                                .font(.system(size: 40))
                                            
                                            Text(genderOption.displayName)
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            gender == genderOption ?
                                            Color(hex: "9C27B0") :
                                            Color.white.opacity(0.3)
                                        )
                                        .cornerRadius(15)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Add Child Button
                    Button(action: handleAddChild) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Add Child")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(hex: "9C27B0"))
                    .cornerRadius(25)
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    .disabled(authViewModel.isLoading)
                    
                    // Cancel Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(childAddedSuccessfully ? "Success" : "Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if childAddedSuccessfully {
                        dismiss()
                    }
                }
            )
        }
    }
    
    private func handleAddChild() {
        // Validate input
        guard !username.isEmpty else {
            alertMessage = "Please enter a username"
            showAlert = true
            return
        }
        
        guard let ageInt = Int(age), ageInt > 0 else {
            alertMessage = "Please enter a valid age"
            showAlert = true
            return
        }
        
        authViewModel.addChild(username: username, age: ageInt, gender: gender.rawValue) { success in
            if success {
                childAddedSuccessfully = true
                alertMessage = "Child added successfully!"
            } else {
                childAddedSuccessfully = false
                alertMessage = authViewModel.errorMessage ?? "Failed to add child"
            }
            showAlert = true
        }
    }
}

#Preview {
    AddChildView()
        .environmentObject(AuthViewModel())
}
