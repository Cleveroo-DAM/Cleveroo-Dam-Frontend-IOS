//
//  LeaderboardView.swift
//  Cleveroo
//
//  Created by GitHub Copilot on 30/11/2025.
//

import SwiftUI

struct LeaderboardView: View {
    @StateObject private var viewModel = GamificationViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var selectedTab = 0 // 0 = Global, 1 = Mes Enfants (pour parent)
    
    var body: some View {
        ZStack {
            BubbleBackground().ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Tabs (seulement pour parent)
                if authViewModel.isParent {
                    Picker("", selection: $selectedTab) {
                        Text("Global").tag(0)
                        Text("Mes Enfants").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .onChange(of: selectedTab) { _ in
                        loadLeaderboard()
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView("Chargement du classement...")
                        .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            if viewModel.leaderboard.isEmpty {
                                EmptyLeaderboardView()
                            } else {
                                ForEach(Array(viewModel.leaderboard.enumerated()), id: \.element.id) { index, entry in
                                    LeaderboardCard(entry: entry, position: index + 1)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("🏆 Classement")
        .onAppear {
            loadLeaderboard()
        }
    }
    
    private func loadLeaderboard() {
        guard let token = authViewModel.currentUserToken else { return }
        
        if authViewModel.isParent && selectedTab == 1 {
            viewModel.loadMyChildrenLeaderboard(token: token)
        } else {
            viewModel.loadLeaderboard(token: token)
        }
    }
}

// MARK: - Leaderboard Card
struct LeaderboardCard: View {
    let entry: GamificationLeaderboardEntry
    let position: Int
    
    var medalEmoji: String {
        switch position {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }
    
    var rankColor: Color {
        switch position {
        case 1: return Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
        case 2: return Color(red: 0.75, green: 0.75, blue: 0.75) // Silver
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2) // Bronze
        default: return Color.gray
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank
            ZStack {
                if position <= 3 {
                    Circle()
                        .fill(rankColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text(medalEmoji)
                        .font(.system(size: 28))
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Text("\(position)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                }
            }
            
            // Avatar
            if let avatarURL = entry.avatarURL, !avatarURL.isEmpty {
                AsyncImage(url: URL(string: avatarURL)) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .overlay(
                            Text(String(entry.playerName.prefix(1)).uppercased())
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.purple)
                        )
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.purple.opacity(0.2))
                    .overlay(
                        Text(String(entry.playerName.prefix(1)).uppercased())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    )
                .frame(width: 50, height: 50)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.playerName)
                    .font(.headline)
                    .fontWeight(.bold)
                
                HStack(spacing: 12) {
                    Label("\(entry.level)", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundColor(.purple)
                    
                    if entry.currentStreak > 0 {
                        Label("\(entry.currentStreak)🔥", systemImage: "flame.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    Label("\(entry.unlockedBadgesCount)🏅", systemImage: "rosette")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
            
            Spacer()
            
            // XP
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.xp)")
                    .font(.title3)
                    .fontWeight(.black)
                    .foregroundColor(position <= 3 ? rankColor : .purple)
                
                Text("XP")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: position <= 3 ? rankColor.opacity(0.3) : Color.black.opacity(0.05), radius: 5)
    }
}

// MARK: - Empty Leaderboard
struct EmptyLeaderboardView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Aucun classement")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Commence à jouer pour apparaître dans le classement!")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}
