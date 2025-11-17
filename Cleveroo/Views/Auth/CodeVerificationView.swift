//
//  CodeVerificationView.swift
//  Cleveroo
//
//  Fixed Navigation Issue - 10/11/2025
//

import SwiftUI

struct CodeVerificationView: View {
    let email: String
    let onCodeVerified: (String, String) -> Void  // (email, code)

    @State private var code = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var isVerifying = false // Pour désactiver le bouton après le premier clic

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

                    Text("Enter Verification Code")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text("Enter the 6-digit code sent to \(email)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    TextField("Verification Code", text: $code)
                        .keyboardType(.numberPad)
                        .textFieldStyle(ChildFieldStyle())
                        .padding(.horizontal, 30)

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    Button(action: verifyCode) {
                        Text(isLoading ? "Verifying..." : "Verify Code")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: isVerifying ? [.gray, .gray] : [.purple, .pink.opacity(0.9)],
                                                       startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 6)
                            .opacity(isVerifying ? 0.6 : 1.0)
                    }
                    .padding(.horizontal, 30)
                    .disabled(isLoading || isVerifying)

                    Button("Resend Code") {
                        resendCode()
                    }
                    .foregroundColor(.yellow)
                    .font(.footnote)
                    .padding(.top, 10)
                }
                .padding(.vertical, 50)
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK") {}
        }
        .alert("Validation Error", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
        .navigationTitle("Verify Code")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func verifyCode() {
        let cleanedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validation du code
        guard !cleanedCode.isEmpty else {
            validationMessage = "Please enter the verification code"
            showValidationAlert = true
            return
        }
        
        guard cleanedCode.count == 6 else {
            validationMessage = "Verification code must be 6 digits"
            showValidationAlert = true
            return
        }
        
        guard Int(cleanedCode) != nil else {
            validationMessage = "Please enter a valid numeric code"
            showValidationAlert = true
            return
        }

        isLoading = true
        errorMessage = nil

        let url = URL(string: "http://localhost:3000/auth/verify-reset-code")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "email": email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            "code": cleanedCode
        ]
        
        print("📤 Sending verification request:")
        print("   Email: \(payload["email"] ?? "nil")")
        print("   Code: \(payload["code"] ?? "nil")")
        
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
                
                print("🔍 Status Code: \(statusCode)")
                print("📥 Response Body: \(responseData)")
                
                // Vérifier le message de succès au lieu du status code
                let msg = self.parseErrorMessage(from: data)
                
                // Status 200-299 = succès
                if (200...299).contains(statusCode) {
                    print("✅ Code verified successfully")
                    print("📧 Email: \(self.email)")
                    print("🔢 Code: \(cleanedCode)")
                    print("🚀 Calling onCodeVerified callback NOW")
                    
                    // Désactiver le bouton définitivement après vérification réussie
                    self.isVerifying = true
                    
                    // Appeler directement sans délai - nous sommes déjà sur le main thread
                    self.onCodeVerified(self.email, cleanedCode)
                    
                    print("✨ Callback executed - navigation should happen now")
                    
                } else {
                    // Afficher le message exact du backend
                    let errorMsg = msg ?? "Verification failed"
                    self.errorMessage = errorMsg
                    print("❌ Verification failed: \(errorMsg)")
                    print("📋 Full error response: \(responseData)")
                }
            }
        }.resume()
    }
    
    private func resendCode() {
        let url = URL(string: "http://localhost:3000/auth/forgot-password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["email": email])

        isLoading = true
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                self.isLoading = false
                self.alertMessage = "New code sent to \(self.email)"
                self.showAlert = true
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
    CodeVerificationView(email: "test@example.com") { email, code in
        print("Preview: Code verified - \(email), \(code)")
    }
}
