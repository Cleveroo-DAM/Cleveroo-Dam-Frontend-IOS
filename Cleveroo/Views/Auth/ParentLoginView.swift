//
//  ParentLoginView.swift
//  Cleveroo
//
//  Created on 13/11/2025
//

import SwiftUI

struct ParentLoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    let onBack: () -> Void
    let onRegister: () -> Void

    @State private var email = ""
    @State private var rememberMe = false
    @State private var animateButton = false
    @State private var showContent = false
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var showForgotPasswordFlow = false

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
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showContent)

                    Text("Welcome Back, Parent! 👨‍👩‍👧")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.3), radius: 5)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    VStack(spacing: 20) {
                        // Email Field
                        TextField("📧 Email Address", text: $email)
                            .textFieldStyle(ChildFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)

                        // Password Field
                        SecureFieldWithToggle(placeholder: "🔑 Password", text: $viewModel.password)

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }

                        // Remember Me Checkbox
                        HStack {
                            Button(action: { rememberMe.toggle() }) {
                                HStack(spacing: 8) {
                                    Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                        .foregroundColor(.yellow)
                                    Text("Remember me")
                                        .font(.footnote)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: { showForgotPasswordFlow = true }) {
                                Text("Forgot Password?")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.yellow)
                            }
                        }
                        .padding(.horizontal, 30)

                        // Login Button
                        Button(action: loginAction) {
                            Text(viewModel.isLoading ? "Loading..." : "🚀 Login")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(colors: [.purple, .pink.opacity(0.9)],
                                                           startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                                .shadow(radius: 6)
                                .scaleEffect(animateButton ? 1.05 : 1.0)
                        }
                        .disabled(viewModel.isLoading)

                        // Register Link
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.footnote)
                            
                            Button(action: onRegister) {
                                Text("Register")
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                                    .font(.footnote)
                            }
                        }
                        .padding(.top, 10)

                        // Back to Role Selection Button
                        Button(action: {
                            print("🔙 Back button clicked - dismissing ParentLoginView")
                            onBack()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back to Role Selection")
                            }
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.yellow)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 30)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                }
                .padding(.vertical, 50)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) { showContent = true }
        }
        .sheet(isPresented: $showForgotPasswordFlow) {
            ForgotPasswordFlow()
        }
        .alert("Validation Error", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
    }

    private func loginAction() {
        // Validation des champs
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
        
        guard !viewModel.password.isEmpty else {
            validationMessage = "Please enter your password"
            showValidationAlert = true
            return
        }
        
        guard viewModel.password.count >= 6 else {
            validationMessage = "Password must be at least 6 characters"
            showValidationAlert = true
            return
        }
        
        // Si validation OK, procéder au login
        animateButton = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            animateButton = false
            viewModel.isParent = true
            viewModel.identifier = email
            viewModel.login(identifier: email, rememberMe: rememberMe)

            // Navigation handled by RootView observing viewModel.isLoggedIn
        }
    }
}

#Preview {
    ParentLoginView(viewModel: AuthViewModel(), onBack: {}, onRegister: {})
}
