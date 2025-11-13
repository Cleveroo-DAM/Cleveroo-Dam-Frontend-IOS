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
    @State private var showSuccess = false
    @State private var showValidationAlert = false
    @State private var validationMessage = ""

    var body: some View {
        ZStack {
            BubbleBackground().ignoresSafeArea()

            if showSuccess {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.green)

                    Text("Password Updated!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text("Redirecting to login...")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .onAppear {
                    // Rediriger automatiquement vers le login après 2 secondes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        print("✅ Redirecting to login after successful password reset")
                        onPasswordReset()
                    }
                }
            } else {
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
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "email": email,
            "code": verificationCode,
            "newPassword": newPassword,
            "confirmPassword": confirmPassword
        ])

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                    withAnimation {
                        self.showSuccess = true
                    }
                } else {
                    let msg = self.parseErrorMessage(from: data)
                    self.errorMessage = msg ?? "Failed to reset password."
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
