//
//  GamesMenuView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 24/11/2025.
//

import SwiftUI

struct GamesMenuView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("🎮 Centre des Jeux")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.primary)
                    
                    Text("Choisis ton type de jeu préféré")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Menu des différents types de jeux
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    
                    // Jeux AI personnalisés
                    NavigationLink(destination: AIGamesListView()) {
                        GameMenuCard(
                            title: "Jeux IA",
                            subtitle: "Jeux personnalisés par l'intelligence artificielle",
                            icon: "brain.head.profile",
                            gradient: [Color.blue, Color.purple],
                            isNew: true
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Mini-jeux existants
                    NavigationLink(destination: MiniGamesView()) {
                        GameMenuCard(
                            title: "Mini-Jeux",
                            subtitle: "Jeux rapides et amusants",
                            icon: "gamecontroller.fill",
                            gradient: [Color.green, Color.blue]
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Jeu de mémoire existant
                    NavigationLink(destination: Text("Jeu de Mémoire - À venir")) {
                        GameMenuCard(
                            title: "Mémoire",
                            subtitle: "Entraîne ta mémoire",
                            icon: "brain.head.profile.fill",
                            gradient: [Color.orange, Color.pink],
                            isComingSoon: true
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Mathématiques mentales
                    NavigationLink(destination: Text("Math Games - À venir")) {
                        GameMenuCard(
                            title: "Maths",
                            subtitle: "Calcul mental",
                            icon: "function",
                            gradient: [Color.purple, Color.red],
                            isComingSoon: true
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                
                // Section recommandations (si l'enfant a joué à des jeux AI)
                RecommendationsSection()
                
                Spacer(minLength: 100) // Espace pour le bottom tab
            }
        }
        .navigationTitle("Jeux")
        .navigationBarHidden(true)
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

struct GameMenuCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    var isNew: Bool = false
    var isComingSoon: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon avec badge
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                // Badge "Nouveau" ou "Bientôt"
                if isNew {
                    VStack {
                        HStack {
                            Spacer()
                            Text("NOUVEAU")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .cornerRadius(6)
                        }
                        Spacer()
                    }
                    .offset(x: 10, y: -10)
                } else if isComingSoon {
                    VStack {
                        HStack {
                            Spacer()
                            Text("BIENTÔT")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .cornerRadius(6)
                        }
                        Spacer()
                    }
                    .offset(x: 10, y: -10)
                }
            }
            
            // Texte
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .opacity(isComingSoon ? 0.6 : 1.0)
    }
}

struct RecommendationsSection: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var aiGameViewModel = AIGameViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🌟 Recommandé pour toi")
                .font(.title3.weight(.semibold))
                .padding(.horizontal)
            
            if aiGameViewModel.availableGames.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                    
                    Text("Aucun jeu personnalisé pour l'instant")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Demande à tes parents de créer des jeux pour toi !")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(aiGameViewModel.availableGames.prefix(3)) { game in
                            CompactAIGameCard(game: game) {
                                aiGameViewModel.startNewGame(game)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            let token = authViewModel.currentUserToken
            if let token = token {
                aiGameViewModel.loadAvailableGames(token: token)
            }
        }
    }
}

struct CompactAIGameCard: View {
    let game: GeneratedGame
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    DomainBadge(domain: game.domain)
                    Spacer()
                    Text("\(game.durationSeconds / 60)min")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Text(game.title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Image(systemName: "person.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("\(game.recommendedAgeMin)+ ans")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: "play.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .frame(width: 140)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        GamesMenuView()
            .environmentObject(AuthViewModel())
    }
}
