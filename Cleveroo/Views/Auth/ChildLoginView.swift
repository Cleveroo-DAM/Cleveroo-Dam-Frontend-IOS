//
//  ChildLoginView.swift
//  Cleveroo
//
//  Created on 13/11/2025
//

import SwiftUI

struct ChildLoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var animateButton = false
    @State private var showContent = false
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var showQRLogin = false

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

                    Text("Welcome Back, Little Hero! 🎮")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.3), radius: 5)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    VStack(spacing: 20) {
                        // Username Field
                        TextField("👶 Child Username", text: $username)
                            .textFieldStyle(ChildFieldStyle())
                            .autocapitalization(.none)

                        // Password Field
                        SecureFieldWithToggle(placeholder: "🔑 Password", text: $viewModel.password)

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }

                        // Login Button
                        Button(action: loginAction) {
                            Text(viewModel.isLoading ? "Loading..." : "🚀 Let's Play!")
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
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 1)
                            Text("OR")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 10)
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.vertical, 5)
                        
                        // QR Login Button
                        NavigationLink(destination: ChildQRCodeLoginView(viewModel: viewModel)) {
                            HStack(spacing: 10) {
                                Image(systemName: "qrcode.viewfinder")
                                    .font(.system(size: 20))
                                Text("Login with QR Code")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: Color.blue.opacity(0.4), radius: 6)
                        }
                        .disabled(viewModel.isLoading)

                        // Back to Role Selection Button
                        Button(action: {
                            print("🔙 Back button clicked - dismissing ChildLoginView")
                            dismiss()
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
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) { showContent = true }
        }
        .alert("Validation Error", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
    }

    private func loginAction() {
        // Validation des champs
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            validationMessage = "Please enter your username"
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
            viewModel.isParent = false
            viewModel.identifier = username
            viewModel.login(identifier: username, rememberMe: false)

            // Navigation handled by RootView observing viewModel.isLoggedIn
        }
    }
}

#Preview {
    ChildLoginView(viewModel: AuthViewModel())
}
