//
//  AIGameParentDashboardView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 24/11/2025.
//

import SwiftUI

struct AIGameParentDashboardView: View {
    @StateObject private var viewModel = AIGameParentViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingCreateGame = false
    @State private var selectedChildId: String?
    
    // Mock data pour les enfants - à remplacer par les vraies données
    @State private var children: [Child] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Section création de jeux
                    createGameSection
                    
                    // Section enfants et progrès
                    if !children.isEmpty {
                        childrenProgressSection
                    }
                    
                    // Section jeux générés récemment
                    if !viewModel.generatedGames.isEmpty {
                        recentGamesSection
                    }
                }
                .padding()
            }
            .navigationTitle("Jeux IA - Dashboard")
            .onAppear {
                // S'assurer que le token est toujours initialisé
                let token = authViewModel.currentUserToken ?? UserDefaults.standard.string(forKey: "jwt") ?? ""
                if !token.isEmpty {
                    viewModel.setParentToken(token)
                    print("🔑 AIGameParentDashboard: Token set with length: \(token.count)")
                }
                loadChildrenData()
            }
            .sheet(isPresented: $showingCreateGame) {
                CreateAIGameView(viewModel: viewModel)
                    .environmentObject(authViewModel)
            }
        }
    }
    
    private var createGameSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Créer un Nouveau Jeu")
                .font(.title2.weight(.semibold))
            
            Button(action: { showingCreateGame = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Générer un jeu IA")
                            .font(.headline)
                        Text("Créez un jeu personnalisé pour vos enfants")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var childrenProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progrès des Enfants")
                .font(.title2.weight(.semibold))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(children) { child in
                    ChildProgressCard(
                        child: child,
                        progress: viewModel.childProgress[child.id ?? ""],
                        onTap: {
                            selectedChildId = child.id
                            if let childId = child.id {
                                viewModel.loadChildProgress(childId: childId)
                            }
                        }
                    )
                }
            }
        }
    }
    
    private var recentGamesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Jeux Créés Récemment")
                .font(.title2.weight(.semibold))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.generatedGames.prefix(5)) { game in
                        CompactGameCard(game: game)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func loadChildrenData() {
        // TODO: Charger les vrais enfants depuis l'API
        // Pour l'instant, on utilise des données mock
        children = [
            Child(id: "child1", username: "Alice", age: 7),
            Child(id: "child2", username: "Bob", age: 9)
        ]
        
        // Charger les progrès pour chaque enfant
        for child in children {
            if let childId = child.id {
                viewModel.loadChildProgress(childId: childId)
            }
        }
    }
}

struct ChildProgressCard: View {
    let child: Child
    let progress: ChildProgressResponse?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    // Avatar de l'enfant
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(child.username.prefix(1).uppercased()))
                                .font(.headline.weight(.bold))
                                .foregroundColor(.blue)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(child.username)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("\(child.age) ans")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                if let progress = progress {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Sessions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(progress.completedSessions)")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.green)
                        }
                        
                        if let avgAccuracy = progress.avgAccuracy {
                            HStack {
                                Text("Précision moy.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(Int(avgAccuracy * 100))%")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        if progress.inProgress > 0 {
                            HStack {
                                Text("En cours")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(progress.inProgress)")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                } else {
                    Text("Chargement...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CompactGameCard: View {
    let game: GeneratedGame
    
    var body: some View {
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
            
            if let description = game.description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text("\(game.recommendedAgeMin)+ ans")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .frame(width: 180)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    AIGameParentDashboardView()
        .environmentObject(AuthViewModel())
}
