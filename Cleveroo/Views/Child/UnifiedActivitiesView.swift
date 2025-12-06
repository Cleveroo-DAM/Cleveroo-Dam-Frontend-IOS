//
//  UnifiedActivitiesView.swift
//  Cleveroo
//
//  Created by GitHub Copilot on 30/11/2025.
//

import SwiftUI

struct UnifiedActivitiesView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedSegment = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                BubbleBackground().ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 10) {
                        Text("🎯 My Activities")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Tasks, Assignments & Games")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 15)
                    
                    // Segmented Control
                    Picker("", selection: $selectedSegment) {
                        Text("Tasks").tag(0)
                        Text("Assignments").tag(1)
                        Text("Games").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 15)
                    .colorMultiply(.white)
                    
                    // Content based on selected segment
                    TabView(selection: $selectedSegment) {
                        // Tasks (Activities)
                        ChildDashboardContent(authVM: authViewModel)
                            .tag(0)
                        
                        // Assignments
                        AssignmentChildDashboardContent()
                            .environmentObject(authViewModel)
                            .tag(1)
                        
                        // Games
                        GamesMenuContent()
                            .environmentObject(authViewModel)
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Child Dashboard Content (Tasks)
struct ChildDashboardContent: View {
    @ObservedObject var authVM: AuthViewModel
    @StateObject private var activityVM = ActivityViewModel()
    @StateObject private var gamificationVM = GamificationViewModel()
    @State private var showContent = false
    @State private var selectedAssignment: ActivityAssignment?
    @State private var showGameWebView = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                // Your Progress Card
                if let profile = gamificationVM.profile {
                    YourProgressCard(profile: profile)
                        .padding(.horizontal, 20)
                }
                
                // Activities List
                if activityVM.isLoading {
                    VStack(spacing: 20) {
                        Spacer()
                            .frame(height: 50)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Spacer()
                            .frame(height: 50)
                    }
                } else if activityVM.myAssignments.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                            .frame(height: 50)
                        Image(systemName: "tray")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("No tasks yet")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("Your parent will assign tasks for you")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Spacer()
                            .frame(height: 50)
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                } else {
                    VStack(spacing: 15) {
                        ForEach(Array(activityVM.myAssignments.enumerated()), id: \.element.id) { index, assignment in
                            ChildActivityCard(assignment: assignment) {
                                selectedAssignment = assignment
                                showGameWebView = true
                            }
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.1), value: showContent)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 15)
        }
        .onAppear {
            activityVM.fetchMyActivities()
            if let token = authVM.currentUserToken {
                gamificationVM.loadMyProfile(token: token)
            }
            withAnimation(.easeInOut(duration: 0.6)) {
                showContent = true
            }
        }
        .sheet(isPresented: $showGameWebView) {
            if let assignment = selectedAssignment {
                GameWebView(assignment: assignment, activityVM: activityVM) {
                    activityVM.fetchMyActivities()
                }
            }
        }
    }
}

// MARK: - Assignment Child Dashboard Content
struct AssignmentChildDashboardContent: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        AssignmentChildDashboardView()
            .environmentObject(authViewModel)
    }
}

// MARK: - Games Menu Content
struct GamesMenuContent: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Mini Games
                NavigationLink(destination: MiniGamesView().environmentObject(authViewModel)) {
                    GameCategoryCard(
                        icon: "🎮",
                        title: "Mini Games",
                        description: "Quick & Fun Games",
                        color1: .purple,
                        color2: .pink
                    )
                }
                
                // Memory Game
                NavigationLink(destination: MemoryGameListView().environmentObject(authViewModel)) {
                    GameCategoryCard(
                        icon: "🧠",
                        title: "Memory Game",
                        description: "Train your memory",
                        color1: .blue,
                        color2: .cyan
                    )
                }
                
                // AI Games
                NavigationLink(destination: AIGamesListView().environmentObject(authViewModel)) {
                    GameCategoryCard(
                        icon: "🤖",
                        title: "AI Games",
                        description: "Smart & Adaptive Games",
                        color1: .green,
                        color2: .mint
                    )
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Game Category Card
struct GameCategoryCard: View {
    let icon: String
    let title: String
    let description: String
    let color1: Color
    let color2: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.system(size: 48))
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.title3)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [color1.opacity(0.7), color2.opacity(0.7)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(20)
        .shadow(color: color1.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    UnifiedActivitiesView()
        .environmentObject(AuthViewModel())
}
