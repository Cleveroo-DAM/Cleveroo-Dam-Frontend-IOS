//
//  RoleSelectionView.swift
//  Cleveroo
//
//  Created on 13/11/2025
//

import SwiftUI

struct RoleSelectionView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showContent = false
    @State private var selectedRole: AuthViewModel.UserRole?
    @State private var showLoginView = false
    @State private var isLoggedIn = false
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoggedIn {
                    MainTabView(viewModel: authViewModel, onLogout: {
                        isLoggedIn = false
                        authViewModel.logout()
                    })
                } else if showLoginView {
                    if selectedRole == .child {
                        ChildLoginView(onLoginSuccess: {
                            isLoggedIn = true
                        })
                    } else if selectedRole == .parent {
                        ParentLoginView(onLoginSuccess: {
                            isLoggedIn = true
                        })
                    }
                } else {
                    roleSelectionContent
                }
            }
        }
    }
    
    private var roleSelectionContent: some View {
        ZStack {
            BubbleBackground().ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Logo et titre
                    VStack(spacing: 20) {
                        Image("Cleveroo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .shadow(color: .white.opacity(0.8), radius: 20)
                            .scaleEffect(showContent ? 1.0 : 0.8)
                            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showContent)
                        
                        Text("Who's Playing?")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 5)
                        
                        Text("Choose your profile to continue")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : -20)
                    
                    // Boutons de sélection
                    VStack(spacing: 25) {
                        // Bouton Enfant
                        Button(action: {
                            print("🔵 Child button clicked!")
                            selectedRole = .child
                            print("🔵 selectedRole set to: \(String(describing: selectedRole))")
                            showLoginView = true
                            print("🔵 showLoginView set to: \(showLoginView)")
                        }) {
                            RoleCard(
                                icon: "👶",
                                title: "I'm a Child",
                                subtitle: "Play and Learn!",
                                colors: [.purple, .pink],
                                isSelected: selectedRole == .child
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.1), value: showContent)
                        
                        // Bouton Parent
                        Button(action: {
                            print("🟢 Parent button clicked!")
                            selectedRole = .parent
                            print("🟢 selectedRole set to: \(String(describing: selectedRole))")
                            showLoginView = true
                            print("🟢 showLoginView set to: \(showLoginView)")
                        }) {
                            RoleCard(
                                icon: "👨‍👩‍👧",
                                title: "I'm a Parent",
                                subtitle: "Monitor & Support",
                                colors: [.blue, .cyan],
                                isSelected: selectedRole == .parent
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.2), value: showContent)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Footer
                    Text("🎮 Let's start your adventure! 🚀")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(showContent ? 1 : 0)
                        .padding(.bottom, 30)
                }
            }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                showContent = true
            }
        }
    }
}

struct RoleCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let colors: [Color]
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            Text(icon)
                .font(.system(size: 70))
                .shadow(color: .black.opacity(0.2), radius: 5)
            
            VStack(spacing: 5) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.6), lineWidth: 2)
        )
        .shadow(color: colors[0].opacity(0.5), radius: 15, x: 0, y: 8)
    }
}

#Preview {
    RoleSelectionView()
}
