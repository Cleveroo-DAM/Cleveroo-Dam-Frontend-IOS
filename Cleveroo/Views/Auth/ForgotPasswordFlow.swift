//
//  ForgotPasswordFlow.swift
//  Cleveroo
//
//  Fixed Alert Display - 17/11/2025
//

import SwiftUI

enum ResetStep: Equatable {
    case enterEmail
    case verifyCode(email: String)
    case resetPassword(email: String, code: String)
    case success
}

struct ForgotPasswordFlow: View {
    @State private var currentStep: ResetStep = .enterEmail
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                switch currentStep {
                case .enterEmail:
                    ForgotPasswordView { email in
                        print("📧 Email verified, moving to code verification")
                        currentStep = .verifyCode(email: email)
                    }
                    
                case .verifyCode(let email):
                    CodeVerificationView(email: email) { verifiedEmail, code in
                        print("🔐 Code verified, moving to reset password")
                        currentStep = .resetPassword(email: verifiedEmail, code: code)
                    }
                    .navigationTitle("Verify Code")
                    .navigationBarTitleDisplayMode(.inline)
                    
                case .resetPassword(let email, let code):
                    ResetPasswordWithVCodeView(
                        email: email,
                        verificationCode: code
                    ) {
                        print("✅ Password reset complete!")
                        print("🔔 Moving to success state...")
                        currentStep = .success
                    }
                    .navigationTitle("New Password")
                    .navigationBarTitleDisplayMode(.inline)
                    
                case .success:
                    SuccessResetView {
                        print("🔄 Dismissing to parent login")
                        dismiss()
                    }
                }
            }
            .navigationTitle(currentStep == .enterEmail ? "Forgot Password" : "")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SuccessResetView: View {
    let onLoginTapped: () -> Void
    
    var body: some View {
        ZStack {
            BubbleBackground().ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Checkmark Icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.green)
                    .scaleEffect(1.2)
                
                // Success Title
                VStack(spacing: 12) {
                    Text("✅ Password Reset Successful!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Your password has been successfully reset.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                
                Spacer()
                
                // Login Button
                Button(action: onLoginTapped) {
                    Text("🚀 Back to Login")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [.purple, .pink.opacity(0.9)],
                                                   startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 6)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ForgotPasswordFlow()
}
