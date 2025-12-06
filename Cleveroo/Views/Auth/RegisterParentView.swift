//
//  RegisterParentView.swift
//  Cleveroo
//
//  Created for parent-only registration
//

import SwiftUI

struct RegisterParentView: View {
    @ObservedObject var viewModel: AuthViewModel
    let onBack: () -> Void
    
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showContent = false
    @State private var animateButton = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    
    var body: some View {
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
                        
                        Text("Create Parent Account 👨‍👩‍👧")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Register to manage your children's learning")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 30)
                    
                    VStack(spacing: 14) {
                        TextField("📧 Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textFieldStyle(ChildFieldStyle())
                        
                        TextField("📱 Phone Number", text: $phone)
                            .keyboardType(.phonePad)
                            .textFieldStyle(ChildFieldStyle())
                        
                        SecureFieldWithToggle(placeholder: "🔑 Password", text: $password)
                        
                        SecureFieldWithToggle(placeholder: "✅ Confirm Password", text: $confirmPassword)
                    }
                    .padding(.horizontal)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: registerAction) {
                        Text(viewModel.isLoading ? "Creating Account..." : "✨ Create Account ✨")
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
                    .disabled(viewModel.isLoading)
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.footnote)
                        
                        Button(action: {
                            onBack()
                        }) {
                            Text("Login")
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                                .font(.footnote)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.bottom, 60)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    showContent = true
                }
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK") {
                    showAlert = false
                    if viewModel.isRegistered {
                        print("✅ Registration successful, redirecting to login")
                        onBack()
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
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            validationMessage = "Please enter your email address"
            showValidationAlert = true
            return
        }
        
        guard email.contains("@") && email.contains(".") else {
            validationMessage = "Please enter a valid email address"
            showValidationAlert = true
            return
        }
        
        guard !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            validationMessage = "Please enter your phone number"
            showValidationAlert = true
            return
        }
        
        // Remove spaces and special characters for validation
        let cleanedPhone = phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "+", with: "")
        
        guard cleanedPhone.count >= 8 else {
            validationMessage = "Please enter a valid phone number (at least 8 digits)"
            showValidationAlert = true
            return
        }
        
        // Check if phone contains only digits after cleaning
        guard cleanedPhone.allSatisfy({ $0.isNumber }) else {
            validationMessage = "Phone number should contain only digits, spaces, or hyphens"
            showValidationAlert = true
            return
        }
        
        guard !password.isEmpty else {
            validationMessage = "Please enter a password"
            showValidationAlert = true
            return
        }
        
        guard password.count >= 6 else {
            validationMessage = "Password must be at least 6 characters"
            showValidationAlert = true
            return
        }
        
        guard password == confirmPassword else {
            validationMessage = "Passwords do not match"
            showValidationAlert = true
            return
        }
        
        animateButton = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            animateButton = false
            
            // Format phone number: remove spaces and special characters
            let formattedPhone = phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
            
            viewModel.registerParent(email: email, phone: formattedPhone, password: password, confirmPassword: confirmPassword) { success, error in
                if success {
                    alertMessage = "✅ Account created successfully! You can now login."
                    showAlert = true
                } else {
                    validationMessage = error ?? "Registration failed"
                    showValidationAlert = true
                }
            }
        }
    }
}

#Preview {
    RegisterParentView(viewModel: AuthViewModel(), onBack: {})
}
