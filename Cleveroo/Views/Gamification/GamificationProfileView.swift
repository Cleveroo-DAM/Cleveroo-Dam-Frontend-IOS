//
//  GamificationProfileView.swift
//  Cleveroo
//
//  Created by GitHub Copilot on 30/11/2025.
//

import SwiftUI

struct GamificationProfileView: View {
    @StateObject private var viewModel = GamificationViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            BubbleBackground().ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("Chargement...")
                            .padding()
                    } else if let profile = viewModel.profile {
                        // Header avec Level et XP
                        ProfileHeaderCard(profile: profile)
                        
                        // Stats Card
                        if let stats = profile.stats {
                            StatsCard(stats: stats)
                        }
                        
                        // Badges Card
                        BadgesCard(badges: viewModel.badges)
                        
                        // Streak Card
                        StreakCard(streak: profile.currentStreak)
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding()
            }
        }
        .navigationTitle("🎮 Mon Profil")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: LeaderboardView().environmentObject(authViewModel)) {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                        Text("Classement")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .onAppear {
            if let token = authViewModel.currentUserToken {
                viewModel.loadMyProfile(token: token)
                viewModel.loadMyBadges(token: token)
            }
        }
    }
}

// MARK: - Profile Header Card
struct ProfileHeaderCard: View {
    let profile: GamificationProfile
    
    var body: some View {
        VStack(spacing: 16) {
            // Level Badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(radius: 10)
                
                VStack(spacing: 4) {
                    Text("NIVEAU")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(profile.level)")
                        .font(.system(size: 48, weight: .black))
                        .foregroundColor(.white)
                }
            }
            
            // XP Progress
            VStack(spacing: 8) {
                HStack {
                    Text("XP: \(profile.xp)")
                        .font(.headline)
                        .foregroundColor(.purple)
                    
                    Spacer()
                    
                    Text("\(profile.xpToNextLevel) XP restants")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple, Color.blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(profile.progressToNextLevel))
                    }
                }
                .frame(height: 20)
                
                Text("Niveau \(profile.level + 1) dans \(profile.xpToNextLevel) XP")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

// MARK: - Stats Card
struct StatsCard: View {
    let stats: GamificationStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📊 Statistiques")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatItem(icon: "🎮", title: "Jeux", value: "\(stats.totalGames ?? 0)")
                StatItem(icon: "📝", title: "Activités", value: "\(stats.totalActivities ?? 0)")
                StatItem(icon: "🧮", title: "Calcul Mental", value: "\(stats.totalMentalMath ?? 0)")
                StatItem(icon: "⭐", title: "Étoiles", value: "\(stats.starsCollected ?? 0)")
                
                if let avg = stats.creativityAvg {
                    StatItem(icon: "🎨", title: "Créativité", value: "\(avg)%")
                }
                
                if let rt = stats.fastestReactionTime {
                    StatItem(icon: "⚡", title: "Réaction", value: "\(rt)ms")
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 32))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.purple)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Badges Card
struct BadgesCard: View {
    let badges: [BadgeWithStatus]
    
    var unlockedBadges: [BadgeWithStatus] {
        badges.filter { $0.unlocked }
    }
    
    var lockedBadges: [BadgeWithStatus] {
        badges.filter { !$0.unlocked }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🏅 Badges")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(unlockedBadges.count)/\(badges.count)")
                    .font(.headline)
                    .foregroundColor(.purple)
            }
            
            if !unlockedBadges.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Débloqués")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(unlockedBadges) { badge in
                            BadgeItem(badge: badge)
                        }
                    }
                }
            }
            
            if !lockedBadges.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Verrouillés")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(lockedBadges) { badge in
                            BadgeItem(badge: badge)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

struct BadgeItem: View {
    let badge: BadgeWithStatus
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(badge.unlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Text(badge.icon)
                    .font(.system(size: 32))
                    .opacity(badge.unlocked ? 1.0 : 0.3)
                    .grayscale(badge.unlocked ? 0 : 1)
            }
            
            Text(badge.name)
                .font(.caption)
                .fontWeight(badge.unlocked ? .bold : .regular)
                .foregroundColor(badge.unlocked ? .primary : .gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }
}

// MARK: - Streak Card
struct StreakCard: View {
    let streak: Int
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Text("🔥")
                    .font(.system(size: 32))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Série Actuelle")
                    .font(.headline)
                
                Text("\(streak) jours consécutifs")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                if streak >= 7 {
                    Text("Incroyable! Continue! 🎉")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("Continue à jouer chaque jour!")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}
