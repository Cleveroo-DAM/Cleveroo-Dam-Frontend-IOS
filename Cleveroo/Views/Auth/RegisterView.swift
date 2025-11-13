//
//  RegisterView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/11/2025.
//

import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: AuthViewModel
    var onLoginSuccess: () -> Void

    @State private var showContent = false
    @State private var animateButton = false
    @State private var showStar = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                BubbleBackground().ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 25) {
                        VStack(spacing: 12) {
                            Image("Cleveroo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130, height: 130)
                                .shadow(color: Color.white.opacity(0.8), radius: 20)
                                .scaleEffect(showContent ? 1.02 : 1.0)
                                .animation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: showContent)

                            Text("Welcome to Cleveroo, little explorer! 🌈")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 30)
                        
                        // MARK: Child Info Fields
                        VStack(spacing: 14) {
                            TextField("👶 Child Username", text: $viewModel.childUsername)
                                .textFieldStyle(ChildFieldStyle())
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("👧 Gender")
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.leading, 5)
                                
                                HStack(spacing: 10) {
                                    GenderChoiceView(label: "👦 Boy", isSelected: viewModel.childGender == "👦 Boy") {
                                        viewModel.childGender = "👦 Boy"
                                    }
                                    
                                    GenderChoiceView(label: "👧 Girl", isSelected: viewModel.childGender == "👧 Girl") {
                                        viewModel.childGender = "👧 Girl"
                                    }
                                }
                            }
                            
                            SecureFieldWithToggle(placeholder: "🔑 Password", text: $viewModel.password)
                            SecureFieldWithToggle(placeholder: "✅ Confirm Password", text: $viewModel.confirmPassword)
                            TextField("🎂 Child Age", text: $viewModel.age)
                                .keyboardType(.numberPad)
                                .textFieldStyle(ChildFieldStyle())
                        }
                        .padding(.horizontal)
                        
                        Divider().background(Color.white.opacity(0.3)).padding(.horizontal, 50)
                        
                        // MARK: Parent Info Fields
                        VStack(spacing: 14) {
                            TextField("📧 Parent Email", text: $viewModel.parentEmail)
                                .keyboardType(.emailAddress)
                                .textFieldStyle(ChildFieldStyle())
                            TextField("📱 Parent Phone", text: $viewModel.parentPhone)
                                .keyboardType(.phonePad)
                                .textFieldStyle(ChildFieldStyle())
                        }
                        .padding(.horizontal)
                        
                        // MARK: Error
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        // MARK: Register Button
                        Button(action: registerAction) {
                                                    Text(viewModel.isLoading ? "Loading..." : "✨ Create Accounts ✨")
                                                        .fontWeight(.bold)
                                                        .frame(maxWidth: .infinity)
                                                        .padding()
                                                        .background(LinearGradient(colors: [Color.purple, Color.pink.opacity(0.9)],
                                                                                   startPoint: .leading, endPoint: .trailing))
                                                        .foregroundColor(.white)
                                                        .clipShape(Capsule())
                                                        .shadow(radius: 6)
                                                        .scaleEffect(animateButton ? 1.05 : 1.0)
                                                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: animateButton)
                                                }
                                                .padding(.horizontal)

                                                if viewModel.isRegistered && showStar {
                                                    VStack {
                                                        Image(systemName: "star.fill")
                                                            .font(.system(size: 50))
                                                            .foregroundColor(.yellow)
                                                            .rotationEffect(.degrees(showStar ? 360 : 0))
                                                            .scaleEffect(showStar ? 1.3 : 0.5)
                                                            .animation(.spring(response: 0.6, dampingFraction: 0.5).repeatCount(3, autoreverses: true), value: showStar)

                                                        Text("Yay! Accounts created 🎉")
                                                            .foregroundColor(.white)
                                                            .font(.subheadline)
                                                            .padding(.top, 20)
                                                    }
                                                }
                                            }
                                            .padding(.bottom, 60)
                                        }
                                    }
                                    .onAppear { withAnimation(.easeInOut(duration: 1.0)) { showContent = true } }
                                    .alert(alertMessage, isPresented: $showAlert) {
                                        Button("OK") {
                                            showAlert = false
                                            if viewModel.isRegistered {
                                                print("✅ Registration successful, redirecting to login")
                                                dismiss() // Retour vers le LoginView
                                            }
                                        }
                                    }
                                    .alert("Validation Error", isPresented: $showValidationAlert) {
                                        Button("OK", role: .cancel) {}
                                    } message: {
                                        Text(validationMessage)
                                    }
                                }
                            }

                            private func registerAction() {
                                // Validation des champs
                                guard !viewModel.childUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                                    validationMessage = "Please enter the child's username"
                                    showValidationAlert = true
                                    return
                                }
                                
                                guard !viewModel.childGender.isEmpty else {
                                    validationMessage = "Please select the child's gender"
                                    showValidationAlert = true
                                    return
                                }
                                
                                guard !viewModel.password.isEmpty else {
                                    validationMessage = "Please enter a password"
                                    showValidationAlert = true
                                    return
                                }
                                
                                guard viewModel.password.count >= 6 else {
                                    validationMessage = "Password must be at least 6 characters"
                                    showValidationAlert = true
                                    return
                                }
                                
                                guard viewModel.password == viewModel.confirmPassword else {
                                    validationMessage = "Passwords do not match"
                                    showValidationAlert = true
                                    return
                                }
                                
                                guard !viewModel.age.isEmpty, let age = Int(viewModel.age), age > 0, age < 18 else {
                                    validationMessage = "Please enter a valid age (1-17)"
                                    showValidationAlert = true
                                    return
                                }
                                
                                guard !viewModel.parentEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                                    validationMessage = "Please enter the parent's email"
                                    showValidationAlert = true
                                    return
                                }
                                
                                guard viewModel.parentEmail.contains("@") && viewModel.parentEmail.contains(".") else {
                                    validationMessage = "Please enter a valid email address"
                                    showValidationAlert = true
                                    return
                                }
                                
                                guard !viewModel.parentPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                                    validationMessage = "Please enter the parent's phone number"
                                    showValidationAlert = true
                                    return
                                }
                                
                                guard viewModel.parentPhone.count >= 8 else {
                                    validationMessage = "Please enter a valid phone number"
                                    showValidationAlert = true
                                    return
                                }
                                
                                // Si validation OK, procéder à l'inscription
                                animateButton = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    animateButton = false
                                    viewModel.register()

                                    if viewModel.isRegistered {
                                        alertMessage = "✅ Accounts successfully created!"
                                        showStar = true
                                        showAlert = true
                                    }
                                }
                            }
                        }

                      
// MARK: - GenderChoiceView
struct GenderChoiceView: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.15))
                .cornerRadius(15)
                .overlay(RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.white.opacity(0.8) : Color.white.opacity(0.3), lineWidth: 1))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Preview
#Preview {
    RegisterView(viewModel: AuthViewModel(), onLoginSuccess: {})
}
