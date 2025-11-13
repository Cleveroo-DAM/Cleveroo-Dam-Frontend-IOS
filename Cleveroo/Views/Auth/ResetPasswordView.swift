//
//  ResetPasswordView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/11/2025.
//

import SwiftUI

struct ResetPasswordView: View {
    
    // MARK: - Properties
    let email: String
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccess = false
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AuthViewModel()
    
    // MARK: - Body
    var body: some View {
        ZStack {
            BubbleBackground()
                .ignoresSafeArea()
            
            if showSuccess {
                // ✅ Success Animation
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 180, height: 180)
                            .scaleEffect(showSuccess ? 1 : 0.8)
                            .opacity(showSuccess ? 1 : 0)
                            .animation(.easeOut(duration: 0.4), value: showSuccess)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 100))
                            .foregroundStyle(.green)
                            .scaleEffect(showSuccess ? 1.1 : 0.8)
                            .animation(.spring(response: 0.4, dampingFraction: 0.5), value: showSuccess)
                    }
                    
                    Text("Password Updated!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Your password has been successfully changed.")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Back to Profile")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: 200)
                            .background(LinearGradient(colors: [Color.purple, Color.pink.opacity(0.9)],
                                                       startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 6)
                    }
                    .padding(.top, 20)
                }
                .transition(.scale.combined(with: .opacity))
                
            } else {
                ScrollView {
                    VStack(spacing: 25) {
                        
                        // MARK: Logo
                        Image("Cleveroo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 130, height: 130)
                            .shadow(color: Color.white.opacity(0.8), radius: 20)
                        
                        // MARK: Title & Instructions
                        Text("Change Your Password")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("Enter your old password and your new password below.")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        
                        // MARK: Password Fields
                        VStack(spacing: 15) {
                            SecureFieldWithToggle(placeholder: "🔑 Old Password", text: $oldPassword)
                            
                            SecureFieldWithToggle(placeholder: "🆕 New Password", text: $newPassword)
                            
                            SecureFieldWithToggle(placeholder: "✅ Confirm Password", text: $confirmPassword)
                        }
                        .padding(.horizontal, 30)
                        
                        // MARK: Error Message
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        // MARK: Reset Password Button
                        Button(action: resetPassword) {
                            Text(isLoading ? "Updating..." : "Change Password")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(colors: [Color.purple, Color.pink.opacity(0.9)],
                                                           startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                                .shadow(radius: 6)
                        }
                        .padding(.horizontal, 30)
                        .disabled(isLoading)
                        
                        // MARK: Back to Profile
                        /*Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Text("Back to Profile")
                                .foregroundColor(.yellow)
                                .font(.footnote)
                                .padding(.top, 10)
                        }*/
                    }
                    .padding(.vertical, 50)
                }
            }
        }
        .alert("Validation Error", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
    }
    
    // MARK: - Actions
    private func resetPassword() {
        // Validation des champs
        guard !oldPassword.isEmpty else {
            validationMessage = "Please enter your old password"
            showValidationAlert = true
            return
        }
        
        guard !newPassword.isEmpty else {
            validationMessage = "Please enter a new password"
            showValidationAlert = true
            return
        }
        
        guard newPassword.count >= 6 else {
            validationMessage = "Password must be at least 6 characters"
            showValidationAlert = true
            return
        }
        
        guard !confirmPassword.isEmpty else {
            validationMessage = "Please confirm your new password"
            showValidationAlert = true
            return
        }
        
        guard newPassword == confirmPassword else {
            validationMessage = "Passwords do not match"
            showValidationAlert = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        viewModel.updateParentPassword(
            oldPassword: oldPassword,
            newPassword: newPassword,
            confirmPassword: confirmPassword
        ) { success, error in
            isLoading = false
            if success {
                withAnimation(.spring()) {
                    showSuccess = true
                }
            } else {
                errorMessage = error ?? "Failed to update password."
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ResetPasswordView(email: "parent@example.com")
}

