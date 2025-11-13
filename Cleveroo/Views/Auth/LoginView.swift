//
//  LoginView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/11/2025.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var identifier = ""
    @State private var animateButton = false
    @State private var showContent = false
    @State private var rememberMe = false
    @State private var navigateToProfile = false   // <-- Nouveau

    let roles = ["Parent", "Child"]

    var body: some View {
        NavigationStack {
            ZStack {
                BubbleBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        Image("Cleveroo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 130, height: 130)
                            .shadow(color: Color.white.opacity(0.8), radius: 20)
                            .scaleEffect(showContent ? 1.02 : 1.0) // amplitude plus petite
                            .animation(
                                Animation.easeInOut(duration: 2.0)
                                    .repeatForever(autoreverses: true), value: showContent
                            )
                        
                        Text("Let’s log back into your Cleveroo adventure! 🌈")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Picker("Role", selection: $viewModel.selectedRole) {
                            ForEach(roles, id: \.self) { role in Text(role) }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 40)
                        
                        VStack(spacing: 15) {
                            if viewModel.selectedRole == "Parent" {
                                parentLoginFields
                            } else {
                                childLoginFields
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        HStack {
                            Button(action: { rememberMe.toggle() }) {
                                HStack {
                                    Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                        .foregroundColor(.yellow)
                                    Text("Remember me")
                                        .foregroundColor(.white)
                                        .font(.footnote)
                                }
                            }
                            
                            Spacer()
                            
                            NavigationLink {
                                ForgotPasswordView()
                            } label: {
                                Text("Forgot Password?")
                                    .foregroundColor(.yellow)
                                    .font(.footnote)
                                    .fontWeight(.bold)
                            }
                        }
                        .padding(.horizontal, 40)
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) { animateButton = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                animateButton = false
                                viewModel.login(identifier: identifier, rememberMe: rememberMe)
                                
                                // 🔹 Redirection vers Profile après login réussi
                                if viewModel.isLoggedIn {
                                    navigateToProfile = true
                                }
                            }
                        }) {
                            Text(viewModel.isLoading ? "Loading..." : "✨ Login ✨")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(colors: [Color.purple, Color.pink.opacity(0.9)], startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                                .shadow(radius: 6)
                                .scaleEffect(animateButton ? 1.05 : 1.0)
                        }
                        .padding(.horizontal, 40)
                        
                        // 🔹 NavigationLink caché vers ProfileView
                        NavigationLink(destination: ProfileView(), isActive: $navigateToProfile) {
                            EmptyView()
                        }
                        
                        Button(action: { print("Connect with Google tapped") }) {
                            HStack {
                                Image(systemName: "globe")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Connect with Google")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                            .shadow(radius: 3)
                        }
                        .padding(.horizontal, 40)
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.white.opacity(0.8))
                            NavigationLink {
                                RegisterView()
                            } label: {
                                Text("Register")
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                            }
                        }
                        .padding(.top, 20)
                    }
                    .padding(.bottom, 50)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                if let saved = viewModel.loadSavedIdentifier() {
                    identifier = saved
                    rememberMe = true
                }
                withAnimation(.easeInOut(duration: 1.0)) { showContent = true }
            }
        }
    }
    
    var childLoginFields: some View {
        VStack(spacing: 15) {
            TextField("👶 Child Username", text: $identifier)
                .textFieldStyle(ChildFieldStyle())
            SecureField("🔑 Password", text: $viewModel.password)
                .textFieldStyle(ChildFieldStyle())
        }
    }
    
    var parentLoginFields: some View {
        VStack(spacing: 15) {
            TextField("📧 Parent Email", text: $identifier)
                .keyboardType(.emailAddress)
                .textFieldStyle(ChildFieldStyle())
            SecureField("🔑 Password", text: $viewModel.password)
                .textFieldStyle(ChildFieldStyle())
        }
    }
}

#Preview {
    LoginView()
}
