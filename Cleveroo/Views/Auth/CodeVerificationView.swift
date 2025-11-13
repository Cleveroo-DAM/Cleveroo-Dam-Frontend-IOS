//
//  CodeVerificationView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/11/2025.
//

import SwiftUI

struct CodeVerificationView: View {
    let email: String
    @State private var code = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var navigateToResetPassword = false
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
                    
                    Text("Enter Verification Code")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("A verification code has been sent to \(email).")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    TextField("🔢 Verification Code", text: $code)
                        .keyboardType(.numberPad)
                        .textFieldStyle(ChildFieldStyle())
                        .padding(.horizontal, 30)
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: { verifyCode() }) {
                        Text(isLoading ? "Verifying..." : "Verify Code")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [Color.purple, Color.pink.opacity(0.9)], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 6)
                    }
                    .padding(.horizontal, 30)
                    
                    Button(action: { resendCode() }) {
                        Text("Didn't receive the code? Resend")
                            .foregroundColor(.yellow)
                            .font(.footnote)
                            .padding(.top, 10)
                    }
                    
                    NavigationLink("", isActive: $navigateToResetPassword) {
                        ResetPasswordView(email: email)
                    }
                }
                .padding(.vertical, 50)
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    
    func verifyCode() {
        guard !code.isEmpty else {
            errorMessage = "Please enter the verification code."
            return
        }
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            if code == "1234" { // Dummy code
                navigateToResetPassword = true
            } else {
                errorMessage = "Invalid verification code."
            }
        }
    }
    
    func resendCode() {
        isLoading = true
        errorMessage = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            alertMessage = "✅ A new verification code has been sent to \(email)"
            showAlert = true
        }
    }
}



#Preview {
    CodeVerificationView(email: "test@example.com")
}

