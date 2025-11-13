//
//  HomeView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 7/11/2025.
//

import SwiftUI

struct HomeView: View {
    @State private var showProfile = false
    @State private var showMiniGames = false
    @State private var showAIReport = false
    @State private var animateButton = false
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                BubbleBackground()
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    // 🌈 Header
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
                    
                    // 🧠 Progress Summary
                    VStack(spacing: 8) {
                        Text("Your Progress")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ProgressView(value: 0.6)
                            .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                            .frame(width: 200)
                        
                        Text("Level 3 • Keep going! 💪")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(Color.purple.opacity(0.25))
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1))
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // 🎯 Action Buttons
                    VStack(spacing: 20) {
                        NavigationLink(destination: MiniGamesView()) {
                            HomeActionButton(icon: "🎮", title: "Play Mini-Games", color1: .purple, color2: .pink)
                        }

                        NavigationLink(destination: AIReportView()) {
                            HomeActionButton(icon: "🤖", title: "View My AI Report", color1: .blue, color2: .mint)
                        }

                        NavigationLink(destination: ProfileView()) {
                            HomeActionButton(icon: "👤", title: "My Profile", color1: .orange, color2: .yellow)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Reusable Button Component
struct HomeActionButton: View {
    var icon: String
    var title: String
    var color1: Color
    var color2: Color

    var body: some View {
        HStack {
            Text(icon)
                .font(.title2)
            Text(title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(LinearGradient(colors: [color1, color2.opacity(0.9)],
                                   startPoint: .leading, endPoint: .trailing))
        .foregroundColor(.white)
        .clipShape(Capsule())
        .shadow(radius: 6)
        .scaleEffect(1.02)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: title)
    }
}

#Preview {
    HomeView(viewModel: AuthViewModel())
}
