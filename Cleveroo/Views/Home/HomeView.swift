//
//  HomeView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 7/11/2025.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var animateButton = false

    var body: some View {
        NavigationStack { // ✅ Ajouter NavigationStack ici
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 10) {
                        Text("Hi, \(viewModel.childUsername.isEmpty ? "Explorer" : viewModel.childUsername)! 👋")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(radius: 2)

                        Text("Welcome back to your Cleveroo world 🌎")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 60)
                    .onAppear {
                        // Recharger le profil si le username est vide
                        if viewModel.childUsername.isEmpty && viewModel.isLoggedIn {
                            viewModel.fetchProfile()
                        }
                    }

                    // Progress Summary
                    VStack(spacing: 12) {
                        Text("Your Progress")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        ProgressView(value: 0.6)
                            .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                            .frame(maxWidth: .infinity)
                            .scaleEffect(y: 1.5)

                        Text("Level 3 • Keep going! 💪")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.vertical, 25)
                    .padding(.horizontal, 20)
                    .background(
                        LinearGradient(
                            colors: [Color.pink.opacity(0.5), Color.purple.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.5), lineWidth: 2))
                    .shadow(color: Color.pink.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)

                    Spacer()

                    // Action Buttons
                    VStack(spacing: 20) {
                        NavigationLink(destination: MiniGamesView().environmentObject(viewModel)) {
                            HomeActionButton(icon: "🎮", title: "Play Mini-Games", color1: .purple, color2: .pink)
                        }
                        
                        NavigationLink(destination: GameHistoryView().environmentObject(viewModel)) {
                            HomeActionButton(icon: "📊", title: "My Game History", color1: .orange, color2: .yellow)
                        }

                        NavigationLink(destination: AIReportView()) {
                            HomeActionButton(icon: "🤖", title: "View My AI Report", color1: .blue, color2: .mint)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
            .background(BubbleBackground().ignoresSafeArea())
        }
    }
}

// Reusable Button Component
struct HomeActionButton: View {
    var icon: String
    var title: String
    var color1: Color
    var color2: Color

    var body: some View {
        HStack {
            Text(icon).font(.title2)
            Text(title).fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(LinearGradient(colors: [color1, color2.opacity(0.9)],
                                   startPoint: .leading, endPoint: .trailing))
        .foregroundColor(.white)
        .clipShape(Capsule())
        .shadow(radius: 6)
    }
}

#Preview {
    HomeView(viewModel: AuthViewModel())
}
