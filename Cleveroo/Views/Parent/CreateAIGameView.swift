//
//  CreateAIGameView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 24/11/2025.
//

import SwiftUI
import Combine

struct CreateAIGameView: View {
    @ObservedObject var viewModel: AIGameParentViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var gameTitle = ""
    @State private var selectedDomain = "personality"
    @State private var minAge = 6
    @State private var maxAge: Int? = 10
    @State private var constraints = ""
    @State private var showingPreview = false
    @State private var showSuccessAlert = false
    @State private var generatedGameTitle = ""
    
    let domains = [
        ("personality", "Personnalité", "figure.wave", Color.purple),
        ("creativity", "Créativité", "paintbrush.fill", Color.orange),
        ("attention", "Attention", "eye.fill", Color.green),
        ("social", "Social", "person.2.fill", Color.blue)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background dégradé
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.6),
                        Color.blue.opacity(0.4),
                        Color.cyan.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header avec description
                        headerSection
                        
                        // Formulaire de création
                        VStack(spacing: 20) {
                            titleSection
                            domainSection
                            ageSection
                            constraintsSection
                        }
                        
                        // Aperçu et boutons
                        previewSection
                        actionButtons
                    }
                    .padding()
                }
            }
            .navigationTitle("Créer un Jeu IA")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Initialiser le token parent quand la vue apparaît
                let token = authViewModel.currentUserToken ?? UserDefaults.standard.string(forKey: "jwt") ?? ""
                if !token.isEmpty {
                    viewModel.setParentToken(token)
                    print("🔑 CreateAIGameView: Token set with length: \(token.count)")
                } else {
                    print("❌ CreateAIGameView: No token available")
                }
            }
            .alert("Erreur", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .alert("Jeu créé avec succès !", isPresented: $showSuccessAlert) {
                Button("Retour aux jeux IA") {
                    dismiss()
                }
            } message: {
                Text("Le jeu '\(generatedGameTitle)' a été généré avec succès et est maintenant disponible dans vos jeux IA.")
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Générateur de Jeux IA")
                .font(.title2.weight(.semibold))
            
            Text("Créez des jeux personnalisés qui s'adaptent à la personnalité et aux besoins de votre enfant")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Titre du jeu (optionnel)")
                .font(.headline)
            
            TextField("Laissez vide pour génération automatique", text: $gameTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("Si laissé vide, l'IA générera un titre adapté au domaine choisi")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var domainSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Domaine du jeu")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(domains, id: \.0) { domain in
                    DomainSelectionCard(
                        id: domain.0,
                        name: domain.1,
                        icon: domain.2,
                        color: domain.3,
                        isSelected: selectedDomain == domain.0
                    ) {
                        selectedDomain = domain.0
                    }
                }
            }
        }
    }
    
    private var ageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Âge recommandé")
                .font(.headline)
            
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Âge minimum")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Âge min", selection: $minAge) {
                        ForEach(3...12, id: \.self) { age in
                            Text("\(age) ans").tag(age)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 100)
                }
                
                VStack(spacing: 8) {
                    Text("Âge maximum")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Âge max", selection: Binding(
                        get: { maxAge ?? 12 },
                        set: { maxAge = $0 }
                    )) {
                        ForEach(minAge...12, id: \.self) { age in
                            Text("\(age) ans").tag(age)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 100)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var constraintsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Contraintes spéciales (optionnel)")
                .font(.headline)
            
            TextField("Ex: Éviter les questions sur les animaux, utiliser des couleurs vives...", text: $constraints, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
            
            Text("Décrivez les préférences ou restrictions particulières pour ce jeu")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aperçu du jeu")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Domaine:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(domains.first { $0.0 == selectedDomain }?.1 ?? selectedDomain)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Âge cible:")
                        .foregroundColor(.secondary)
                    Spacer()
                    if let maxAge = maxAge {
                        Text("\(minAge)-\(maxAge) ans")
                            .fontWeight(.medium)
                    } else {
                        Text("\(minAge)+ ans")
                            .fontWeight(.medium)
                    }
                }
                
                if !gameTitle.isEmpty {
                    HStack {
                        Text("Titre:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(gameTitle)
                            .fontWeight(.medium)
                    }
                }
                
                if !constraints.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Contraintes:")
                            .foregroundColor(.secondary)
                        Text(constraints)
                            .font(.caption)
                            .padding(.leading, 8)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: generateGame) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "wand.and.rays")
                    }
                    Text(viewModel.isLoading ? "Génération en cours..." : "Générer le jeu")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isLoading ? Color.gray : Color.blue)
                .cornerRadius(12)
            }
            .disabled(viewModel.isLoading)
            
            Text("La génération peut prendre 10-30 secondes")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
    
    private func generateGame() {
        let request = GenerateGameRequest(
            title: gameTitle.isEmpty ? nil : gameTitle,
            domain: selectedDomain,
            recommendedAgeMin: minAge,
            recommendedAgeMax: maxAge,
            constraints: constraints.isEmpty ? nil : constraints
        )
        
        viewModel.generateNewGame(request: request)
        
        // Observer pour afficher l'alerte de succès quand la génération est terminée
        let cancellable = viewModel.$generatedGames
            .sink { games in
                if let lastGame = games.last, !viewModel.isLoading {
                    generatedGameTitle = lastGame.title
                    showSuccessAlert = true
                }
            }
        
        // Note: Dans une vraie app, il faudrait gérer le cycle de vie du cancellable
    }
}

struct DomainSelectionCard: View {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? color : .secondary)
                
                Text(name)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? color.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CreateAIGameView(viewModel: AIGameParentViewModel())
}
