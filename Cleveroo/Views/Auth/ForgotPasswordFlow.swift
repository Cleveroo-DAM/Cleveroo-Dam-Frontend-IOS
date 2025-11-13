//
//  ForgotPasswordFlow.swift
//  Cleveroo
//
//  Simplified Navigation - 13/11/2025
//

import SwiftUI

enum ResetStep: Equatable {
    case enterEmail
    case verifyCode(email: String)
    case resetPassword(email: String, code: String)
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
                        print("✅ Password reset complete, dismissing flow")
                        dismiss()
                    }
                    .navigationTitle("New Password")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            .navigationTitle(currentStep == .enterEmail ? "Forgot Password" : "")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ForgotPasswordFlow()
}
