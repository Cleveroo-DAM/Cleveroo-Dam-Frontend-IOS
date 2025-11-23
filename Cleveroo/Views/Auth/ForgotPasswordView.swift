//
//  ForgotPasswordView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/11/2025.
//

//
//  ForgotPasswordView.swift
//  Cleveroo
//
//
//  ForgotPasswordView.swift
//  Cleveroo
//

import SwiftUI

struct ForgotPasswordView: View {
    let onCodeSent: (String) -> Void

    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var alertMessage = ""
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

                    Text("Forgot your password?")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Enter your email below and we'll send you a verification code.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(ChildFieldStyle())
                        .padding(.horizontal, 30)

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    Button(action: sendCode) {
                        Text(isLoading ? "Sending..." : "Send Code")
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
        .alert(alertMessage, isPresented: Binding(
            get: { !alertMessage.isEmpty },
            set: { _ in alertMessage = "" }
        )) {
            Button("OK") {}
        }
        .alert("Validation Error", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
    }

    private func sendCode() {
        // Validation de l'email
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard !cleanedEmail.isEmpty else {
            validationMessage = "Please enter your email address"
            showValidationAlert = true
            return
        }

        guard cleanedEmail.contains("@") && cleanedEmail.contains(".") else {
            validationMessage = "Please enter a valid email address"
            showValidationAlert = true
            return
        }

        isLoading = true
        errorMessage = nil

        print("📧 Sending forgot password code for: \(cleanedEmail)")
        
        let url = URL(string: "\(APIConfig.authBaseURL)/forgot-password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["email": cleanedEmail])

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                let responseData = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No response body"
                
                print("🔍 Status Code: \(statusCode)")
                print("📥 Response: \(responseData)")
                
                if (200...299).contains(statusCode) {
                    self.alertMessage = "Check your email at \(cleanedEmail) for the 6-digit code."
                    print("✅ Code sent successfully to: \(cleanedEmail)")
                    self.onCodeSent(cleanedEmail)
                } else {
                    let msg = self.parseErrorMessage(from: data)
                    self.errorMessage = msg ?? "Failed to send code. Please check your email address."
                    print("❌ Failed to send code: \(msg ?? "Unknown error")")
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
    ForgotPasswordView { _ in }
}
