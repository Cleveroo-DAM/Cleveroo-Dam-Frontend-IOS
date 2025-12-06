//
//  GameHistoryView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 15/11/2025.
//

import SwiftUI

struct GameHistoryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = GameHistoryViewModel()
    
    var body: some View {
        ZStack {
            BubbleBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.sessions.isEmpty {
                    emptyStateView
                } else {
                    // Statistics Summary
                    statisticsView
                    
                    // History List
                    historyListView
                }
            }
        }
        .navigationTitle("My History 📊")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            print("🎯 GameHistoryView .task triggered")
            print("🔍 Checking currentChildId...")
            
            if let userId = authViewModel.currentChildId {
                print("✅ Found userId: \(userId)")
                print("📊 Calling loadHistory...")
                
                // ✅ Utiliser le vrai backend
                await viewModel.loadHistory(userId: userId)
            } else {
                print("❌ ERROR: currentChildId is nil!")
                print("   isLoggedIn: \(authViewModel.isLoggedIn)")
                print("   isParent: \(authViewModel.isParent)")
                print("   childUsername: \(authViewModel.childUsername)")
                
                // Essayer de recharger le profil si nécessaire
                if authViewModel.isLoggedIn && authViewModel.currentChildId == nil {
                    print("🔄 Attempting to reload profile...")
                    authViewModel.fetchProfile()
                    
                    // Attendre un peu puis réessayer
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 seconde
                    
                    if let userId = authViewModel.currentChildId {
                        print("✅ Profile reloaded, userId found: \(userId)")
                        await viewModel.loadHistory(userId: userId)
                    } else {
                        print("❌ Still no userId after profile reload")
                    }
                }
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 10) {
            Text("Game History")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Text("Track your amazing progress! 🌟")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.8), Color.pink.opacity(0.6)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
    
    // MARK: - Statistics View
    private var statisticsView: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                StatCard(
                    icon: "🎮",
                    title: "Games Played",
                    value: "\(viewModel.sessions.count)"
                )
                
                StatCard(
                    icon: "⭐",
                    title: "Total Score",
                    value: "\(viewModel.totalScore)"
                )
            }
            
            HStack(spacing: 15) {
                StatCard(
                    icon: "🎯",
                    title: "Best Score",
                    value: "\(viewModel.bestScore)"
                )
                
                StatCard(
                    icon: "🔥",
                    title: "Win Rate",
                    value: "\(viewModel.winRate)%"
                )
            }
        }
        .padding()
    }
    
    // MARK: - History List View
    private var historyListView: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(viewModel.sessions) { session in
                    GameHistoryCard(session: session)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("Loading your history...")
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Text("🎮")
                .font(.system(size: 80))
            
            Text("No games yet!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Start playing to see your history here")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 32))
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.5), Color.cyan.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Game History Card Component
struct GameHistoryCard: View {
    let session: MemoryGameSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with date and status
            HStack {
                Text(formatDate(session.startTime))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                SessionStatusBadge(status: session.status)
            }
            
            // Score and performance
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("Score:")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                        Text("\(session.score)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                    
                    HStack {
                        Text("⏱")
                        Text(formatTime(session.timeSpent))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("•")
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("🎯")
                        Text("\(session.pairsFound) pairs")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Performance indicator
                PerformanceIndicator(session: session)
            }
            
            // Stats bar
            HStack(spacing: 10) {
                StatPill(icon: "🎮", text: "\(session.totalMoves) moves")
                StatPill(icon: "⭐", text: "\(session.perfectPairs) perfect")
                StatPill(icon: "❌", text: "\(session.failedAttempts) fails")
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.5), Color.pink.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy • HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

// MARK: - Session Status Badge Component
private struct SessionStatusBadge: View {
    let status: MemoryGameSession.SessionStatus
    
    var body: some View {
        Text(statusText)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(statusColor)
            .cornerRadius(12)
    }
    
    private var statusText: String {
        switch status {
        case .COMPLETED: return "✅ Completed"
        case .IN_PROGRESS: return "⏳ In Progress"
        case .ABANDONED: return "🚫 Abandoned"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .COMPLETED: return Color.green.opacity(0.8)
        case .IN_PROGRESS: return Color.orange.opacity(0.8)
        case .ABANDONED: return Color.red.opacity(0.8)
        }
    }
}

// MARK: - Performance Indicator Component
struct PerformanceIndicator: View {
    let session: MemoryGameSession
    
    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 6)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: performancePercentage)
                    .stroke(performanceColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(performancePercentage * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Text(performanceLabel)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    private var performancePercentage: CGFloat {
        guard session.totalMoves > 0 else { return 0 }
        let successRate = Double(session.pairsFound * 2) / Double(session.totalMoves)
        return CGFloat(min(successRate, 1.0))
    }
    
    private var performanceColor: Color {
        let percentage = performancePercentage * 100
        switch percentage {
        case 90...100: return .green
        case 75..<90: return .blue
        case 60..<75: return .orange
        default: return .red
        }
    }
    
    private var performanceLabel: String {
        let percentage = performancePercentage * 100
        switch percentage {
        case 90...100: return "Excellent!"
        case 75..<90: return "Great!"
        case 60..<75: return "Good!"
        default: return "Practice!"
        }
    }
}

// MARK: - Stat Pill Component
struct StatPill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(icon)
                .font(.caption)
            Text(text)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        GameHistoryView()
            .environmentObject(AuthViewModel())
    }
}
