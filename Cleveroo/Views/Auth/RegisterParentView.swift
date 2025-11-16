//
//  RegisterParentView.swift
//  Cleveroo
//
//  View for parent registration
//

import SwiftUI

struct RegisterParentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var registrationSuccess = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "9C27B0").opacity(0.9),
                    Color(hex: "98FF98").opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Logo/Title
                    Text("Cleveroo")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 60)
                    
                    Text("Parent Registration")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.bottom, 20)
                    
                    // Form
                    VStack(spacing: 20) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .foregroundColor(.white)
                                .font(.subheadline)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        
                        // Phone Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Phone")
                                .foregroundColor(.white)
                                .font(.subheadline)
                            
                            TextField("Enter your phone number", text: $phone)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.phonePad)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .foregroundColor(.white)
                                .font(.subheadline)
                            
                            SecureField("Enter your password", text: $password)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .foregroundColor(.white)
                                .font(.subheadline)
                            
                            SecureField("Confirm your password", text: $confirmPassword)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Register Button
                    Button(action: handleRegister) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign Up")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(hex: "9C27B0"))
                    .cornerRadius(25)
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    .disabled(authViewModel.isLoading)
                    
                    // Login Link
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Text("Already have an account?")
                                .foregroundColor(.white.opacity(0.8))
                            Text("Login")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(registrationSuccess ? "Success" : "Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if registrationSuccess {
                        dismiss()
                    }
                }
            )
        }
    }
    
    private func handleRegister() {
        authViewModel.registerParent(
            email: email,
            phone: phone,
            password: password,
            confirmPassword: confirmPassword
        ) { success in
            if success {
                registrationSuccess = true
                alertMessage = "Registration successful! Please login."
            } else {
                registrationSuccess = false
                alertMessage = authViewModel.errorMessage ?? "Registration failed"
            }
            showAlert = true
        }
    }
}

// Custom TextField Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(10)
    }
}

#Preview {
    RegisterParentView()
        .environmentObject(AuthViewModel())
}
