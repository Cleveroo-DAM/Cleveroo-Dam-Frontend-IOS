//
//  ResetPasswordView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/11/2025.
//

import SwiftUI

struct ResetPasswordView: View {
    let email: String
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @Environment(\.presentationMode) var presentationMode
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
                        .frame(width: 130, height: 130)
                        .shadow(color: Color.white.opacity(0.8), radius: 20)
                    
                    Text("Reset Your Password")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Enter a new password for your account: \(email)")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    VStack(spacing: 15) {
                        SecureField("🔑 New Password", text: $newPassword)
                            .textFieldStyle(ChildFieldStyle())
                        SecureField("✅ Confirm Password", text: $confirmPassword)
                            .textFieldStyle(ChildFieldStyle())
                    }
                    .padding(.horizontal, 30)
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: { resetPassword() }) {
                        Text(isLoading ? "Resetting..." : "Reset Password")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [Color.purple, Color.pink.opacity(0.9)], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 6)
                    }
                    .padding(.horizontal, 30)
                    
                    // 🔹 Back to Login
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Back to Login")
                            .foregroundColor(.yellow)
                            .font(.footnote)
                            .padding(.top, 10)
                    }
                }
                .padding(.vertical, 50)
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK") {
                // Retour automatique à LoginView après succès
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func resetPassword() {
        guard !newPassword.isEmpty && !confirmPassword.isEmpty else {
            errorMessage = "Please fill in both fields."
            return
        }
        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            alertMessage = "✅ Password successfully reset!"
            showAlert = true
        }
    }
}

// MARK: - Preview
#Preview {
    ResetPasswordView(email: "Test@example.com")
}

