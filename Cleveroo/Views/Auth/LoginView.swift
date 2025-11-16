//
//  LoginView.swift
//  Cleveroo
//
//  View for parent and child login
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var identifier = "" // Email for parent, Username for child
    @State private var password = ""
    @State private var loginType: LoginType = .parent
    @State private var showRegister = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToParentDashboard = false
    @State private var navigateToChildDashboard = false
    
    enum LoginType {
        case parent
        case child
    }
    
    var body: some View {
        NavigationStack {
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
                            .padding(.top, 80)
                        
                        Text("Welcome Back!")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.bottom, 20)
                        
                        // Login Type Picker
                        Picker("Login Type", selection: $loginType) {
                            Text("Parent").tag(LoginType.parent)
                            Text("Child").tag(LoginType.child)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 30)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                        
                        // Form
                        VStack(spacing: 20) {
                            // Identifier Field (Email or Username)
                            VStack(alignment: .leading, spacing: 8) {
                                Text(loginType == .parent ? "Email" : "Username")
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                
                                TextField(
                                    loginType == .parent ? "Enter your email" : "Enter your username",
                                    text: $identifier
                                )
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(loginType == .parent ? .emailAddress : .default)
                                .autocapitalization(loginType == .parent ? .none : .none)
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                
                                SecureField("Enter your password", text: $password)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        // Login Button
                        Button(action: handleLogin) {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Login")
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
                        
                        // Register Link (only for parents)
                        if loginType == .parent {
                            Button(action: {
                                showRegister = true
                            }) {
                                HStack {
                                    Text("Don't have an account?")
                                        .foregroundColor(.white.opacity(0.8))
                                    Text("Sign Up")
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                }
                            }
                            .padding(.top, 10)
                        }
                        
                        Spacer()
                    }
                }
                
                // Navigation Links
                NavigationLink(destination: ParentDashboardView(), isActive: $navigateToParentDashboard) {
                    EmptyView()
                }
                .hidden()
                
                NavigationLink(destination: ChildDashboardView(), isActive: $navigateToChildDashboard) {
                    EmptyView()
                }
                .hidden()
            }
            .sheet(isPresented: $showRegister) {
                RegisterParentView()
                    .environmentObject(authViewModel)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func handleLogin() {
        if loginType == .parent {
            authViewModel.loginParent(email: identifier, password: password) { success in
                if success {
                    navigateToParentDashboard = true
                } else {
                    alertMessage = authViewModel.errorMessage ?? "Login failed"
                    showAlert = true
                }
            }
        } else {
            authViewModel.loginChild(username: identifier, password: password) { success in
                if success {
                    navigateToChildDashboard = true
                } else {
                    alertMessage = authViewModel.errorMessage ?? "Login failed"
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
