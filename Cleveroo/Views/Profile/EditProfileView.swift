//
//  EditProfileView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/11/2025.
//

import SwiftUI

struct EditProfileView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var animateButton = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            BubbleBackground()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    Image("Cleveroo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .shadow(color: Color.white.opacity(0.8), radius: 10)
                        .padding(.top, 40)
                    
                    Text("Edit Your Profile")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 15) {
                        if viewModel.selectedRole == "Child" {
                            TextField("👶 Child Username", text: $viewModel.childUsername)
                                .textFieldStyle(ChildFieldStyle())
                            
                            // 🎀 Gender harmonized field
                            HStack(spacing: 10) {
                                GenderChoiceView(label: "👦 Boy", isSelected: viewModel.childGender == "👦 Boy") {
                                    viewModel.childGender = "👦 Boy"
                                }
                                GenderChoiceView(label: "👧 Girl", isSelected: viewModel.childGender == "👧 Girl") {
                                    viewModel.childGender = "👧 Girl"
                                }
                            }
                            
                            TextField("🎂 Age", text: $viewModel.age)
                                .keyboardType(.numberPad)
                                .textFieldStyle(ChildFieldStyle())
                        }
                        
                        if viewModel.selectedRole == "Parent" {
                            TextField("📧 Parent Email", text: $viewModel.parentEmail)
                                .keyboardType(.emailAddress)
                                .textFieldStyle(ChildFieldStyle())
                            
                            TextField("📱 Parent Phone", text: $viewModel.parentPhone)
                                .keyboardType(.phonePad)
                                .textFieldStyle(ChildFieldStyle())
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Button(action: { saveProfile() }) {
                        Text("Save Changes")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [Color.cyan.opacity(0.7), Color.blue.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 6)
                            .scaleEffect(animateButton ? 1.05 : 1.0)
                    }
                    .padding(.horizontal, 30)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: animateButton)
                }
                .padding(.vertical, 50)
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK") { dismiss() }
        }
    }
    
    func saveProfile() {
        animateButton = true
        viewModel.updateProfile { success in
            animateButton = false
            if success {
                alertMessage = "✅ Profile updated successfully!"
            } else {
                alertMessage = "Please fill in all required fields."
            }
            showAlert = true
        }
    }
}

#Preview {
    EditProfileView()
}
