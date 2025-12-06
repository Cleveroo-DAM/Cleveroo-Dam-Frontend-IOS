//
//  AIGamesListView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 24/11/2025.
//

import SwiftUI

struct AIGamesListView: View {
    @StateObject private var viewModel = AIGameViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Chargement des jeux...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.availableGames.isEmpty {
                    EmptyGamesView()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 160))
                        ], spacing: 16) {
                            ForEach(viewModel.availableGames) { game in
                                AIGameCard(
                                    game: game,
                                    aiGameViewModel: viewModel,
                                    authViewModel: authViewModel,
                                    onTap: {
                                        viewModel.startNewGame(game)
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Jeux AI")
            .onAppear {
                if let token = authViewModel.currentUserToken {
                    viewModel.loadAvailableGames(token: token)
                }
            }
        }
    }
    struct AIGameCard: View {
        let game: GeneratedGame
        let aiGameViewModel: AIGameViewModel
        let authViewModel: AuthViewModel
        let onTap: () -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                // Header avec domaine et temps
                HStack {
                    DomainBadge(domain: game.domain)
                    Spacer()
                    Text("\(game.durationSeconds / 60) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Titre
                Text(game.title)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Description
                if let description = game.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                // Âge recommandé
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                    Text(ageRangeText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                // Bouton jouer - Toujours bleu et dit "Jouer" pour permettre de rejouer
                NavigationLink(destination: AIGameSessionView(
                    viewModel: aiGameViewModel,
                    authViewModel: authViewModel,
                    gameId: game.id
                )) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Jouer")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        
        private var ageRangeText: String {
            if let maxAge = game.recommendedAgeMax {
                return "\(game.recommendedAgeMin)-\(maxAge) ans"
            } else {
                return "\(game.recommendedAgeMin)+ ans"
            }
        }
    }
    
    struct DomainBadge: View {
        let domain: String
        
        var body: some View {
            Text(domainDisplayName)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(domainColor.opacity(0.2))
                .foregroundColor(domainColor)
                .cornerRadius(6)
        }
        
        private var domainDisplayName: String {
            switch domain {
            case "personality": return "Personnalité"
            case "creativity": return "Créativité"
            case "attention": return "Attention"
            case "social": return "Social"
            default: return domain.capitalized
            }
        }
        
        private var domainColor: Color {
            switch domain {
            case "personality": return .purple
            case "creativity": return .orange
            case "attention": return .green
            case "social": return .blue
            default: return .gray
            }
        }
    }
    
    struct EmptyGamesView: View {
        var body: some View {
            VStack(spacing: 16) {
                Image(systemName: "gamecontroller")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                Text("Aucun jeu disponible")
                    .font(.title2.weight(.medium))
                    .foregroundColor(.primary)
                
                Text("Demande à tes parents de créer des jeux pour toi !")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
}
