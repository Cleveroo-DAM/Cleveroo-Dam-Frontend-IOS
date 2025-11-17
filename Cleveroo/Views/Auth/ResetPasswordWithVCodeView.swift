//
//  ResetPasswordWithVCodeView.swift
//  Cleveroo
//
//  Corrigé le 10/11/2025
//
//
//  ResetPasswordWithVCodeView.swift
//  Cleveroo
//

import SwiftUI

struct ResetPasswordWithVCodeView: View {
    let email: String
    let verificationCode: String
    let onPasswordReset: () -> Void

    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showValidationAlert = false
    @State private var validationMessage = ""

    var body: some View {
        ZStack {
            BubbleBackground().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    Image("Cleveroo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 130)
                        .shadow(color: .white.opacity(0.8), radius: 20)

                    Text("Reset Your Password")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    SecureFieldWithToggle(placeholder: "New Password", text: $newPassword)
                        .padding(.horizontal, 30)

                    SecureFieldWithToggle(placeholder: "Confirm Password", text: $confirmPassword)
                        .padding(.horizontal, 30)

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    Button(action: resetPassword) {
                        Text(isLoading ? "Updating..." : "Change Password")
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
                    .disabled(isLoading)
                }
                .padding(.vertical, 50)
            }
        }
        .navigationTitle("New Password")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Validation Error", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
    }

    private func resetPassword() {
        // Validation des champs avec popup
        guard !newPassword.isEmpty else {
            validationMessage = "Please enter a new password"
            showValidationAlert = true
            return
        }
        
        guard !confirmPassword.isEmpty else {
            validationMessage = "Please confirm your password"
            showValidationAlert = true
            return
        }
        
        guard newPassword.count >= 6 else {
            validationMessage = "Password must be at least 6 characters"
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

        let url = URL(string: "http://localhost:3000/auth/reset-password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "email": email,
            "code": verificationCode,
            "newPassword": newPassword,
            "confirmPassword": confirmPassword
        ]
        
        print("📤 Reset Password Request:")
        print("   Email: \(email)")
        print("   Code: \(verificationCode)")
        print("   New Password: \(newPassword)")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                let responseData = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No response body"
                
                print("🔍 Reset Password Status Code: \(statusCode)")
                print("📥 Response Body: \(responseData)")
                
                if (200...299).contains(statusCode) {
                    print("✅ Password reset successful!")
                    print("🔔 Calling onPasswordReset() callback NOW...")
                    self.onPasswordReset()
                    print("✨ Callback executed - alert should appear!")
                } else {
                    let msg = self.parseErrorMessage(from: data)
                    self.errorMessage = msg ?? "Failed to reset password."
                    print("❌ Password reset failed: \(self.errorMessage ?? "Unknown error")")
                }
            }
        }.resume()
    }

    private func parseErrorMessage(from data: Data?) -> String? {
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let message = json["message"] as? String else {
            return nil
        }
        return message
    }
}

#Preview {
    ResetPasswordWithVCodeView(email: "test@example.com", verificationCode: "123456") {}
}
