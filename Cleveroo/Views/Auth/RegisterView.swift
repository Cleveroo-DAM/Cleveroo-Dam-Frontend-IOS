//
//  RegisterView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/11/2025.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showContent = false
    @State private var animateButton = false
    @State private var showStar = false

    var body: some View {
        NavigationStack {
            ZStack {
                BubbleBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // 🌈 Logo + Title
                        VStack(spacing: 12) {
                            Image("Cleveroo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130, height: 130)
                                .shadow(color: Color.white.opacity(0.8), radius: 20)
                                .scaleEffect(showContent ? 1.02 : 1.0)
                                .animation(Animation.easeInOut(duration: 2.0)
                                    .repeatForever(autoreverses: true), value: showContent)
                            
                            Text("Welcome to Cleveroo, little explorer! 🌈")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 30)
                        
                        // 👨‍👩‍👧 Parent/Child Info
                        VStack(spacing: 5) {
                            Text("👨‍👩‍👧 This section is for parents and children")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Parents, fill in your info to help your little explorer start their Cleveroo journey!")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                        }
                        .padding()
                        .background(Color.purple.opacity(0.25))
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1.5))
                        .shadow(color: .white.opacity(0.2), radius: 5, x: 0, y: 3)
                        .padding(.horizontal, 30)
                        
                        // 🧒 Child Info Fields
                        VStack(spacing: 14) {
                            TextField("👶 Child Username", text: $viewModel.childUsername)
                                .textFieldStyle(ChildFieldStyle())
                            
                            // 🧍‍♂️ Harmonized Gender Selector
                            VStack(alignment: .leading, spacing: 6) {
                                Text("👧 Gender")
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.leading, 5)
                                
                                HStack(spacing: 10) {
                                    GenderChoiceView(label: "👦 Boy", isSelected: viewModel.childGender == "👦 Boy") {
                                        viewModel.childGender = "👦 Boy"
                                    }
                                    
                                    GenderChoiceView(label: "👧 Girl", isSelected: viewModel.childGender == "👧 Girl") {
                                        viewModel.childGender = "👧 Girl"
                                    }
                                }
                            }
                            
                            SecureField("🔑 Password", text: $viewModel.password)
                                .textFieldStyle(ChildFieldStyle())
                            SecureField("✅ Confirm Password", text: $viewModel.confirmPassword)
                                .textFieldStyle(ChildFieldStyle())
                            TextField("🎂 Child Age", text: $viewModel.age)
                                .keyboardType(.numberPad)
                                .textFieldStyle(ChildFieldStyle())
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                            .padding(.horizontal, 50)
                        
                        // 📧 Parent Info
                        VStack(spacing: 14) {
                            TextField("📧 Parent Email", text: $viewModel.parentEmail)
                                .keyboardType(.emailAddress)
                                .textFieldStyle(ChildFieldStyle())
                            TextField("📱 Parent Phone", text: $viewModel.parentPhone)
                                .keyboardType(.phonePad)
                                .textFieldStyle(ChildFieldStyle())
                        }
                        .padding(.horizontal)
                        
                        // ⚠️ Error Message
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        // ✨ Register Button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) { animateButton = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                animateButton = false
                                viewModel.register()
                                if viewModel.isRegistered { withAnimation(.spring()) { showStar = true } }
                            }
                        }) {
                            Text(viewModel.isLoading ? "Loading..." : "✨ Create Accounts ✨")
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
                        .padding(.horizontal)
                        
                        // 🌟 Success Animation
                        if viewModel.isRegistered {
                            ZStack {
                                if showStar {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.yellow)
                                        .rotationEffect(.degrees(showStar ? 360 : 0))
                                        .scaleEffect(showStar ? 1.3 : 0.5)
                                        .animation(.spring(response: 0.6, dampingFraction: 0.5)
                                            .repeatCount(3, autoreverses: true), value: showStar)
                                }
                                Text("Yay! Accounts created 🎉")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.top, 80)
                            }
                        }
                        
                        // 🔹 Go to Login
                        NavigationLink(destination: LoginView()) {
                            HStack {
                                Text("Already have an account?")
                                    .foregroundColor(.white.opacity(0.8))
                                Text("Log in")
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                            }
                            .font(.footnote)
                        }
                        .padding(.top, 10)
                        
                    }
                    .padding(.bottom, 60)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) { showContent = true }
            }
        }
    }
}

struct GenderChoiceView: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.15))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(isSelected ? Color.white.opacity(0.8) : Color.white.opacity(0.3), lineWidth: 1)
                )
                .foregroundColor(.white)
        }
    }
}

#Preview {
    RegisterView()
}

