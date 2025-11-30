//
//  AIGameAssignmentView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 24/11/2025.
//

import SwiftUI

struct AIGameAssignmentView: View {
    @StateObject private var viewModel = AIGameAssignmentViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingCreateGame = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header section
                    headerSection
                    
                    // Quick actions
                    quickActionsSection
                    
                    // Available games to assign
                    availableGamesSection
                    
                    // Active assignments overview
                    activeAssignmentsSection
                }
                .padding()
            }
            .navigationTitle("Assigner des Jeux")
            .onAppear {
                if let token = authViewModel.currentUserToken {
                    viewModel.setParentToken(token)
                    viewModel.loadAvailableGames()
                    viewModel.loadAssignments()
                }
            }
            .sheet(isPresented: $viewModel.showingAssignmentSheet) {
                if let selectedGame = viewModel.selectedGame {
                    AssignGameSheet(
                        game: selectedGame,
                        viewModel: viewModel,
                        children: authViewModel.childrenList.compactMap { childData in
                            guard let id = childData["_id"] as? String,
                                  let username = childData["username"] as? String,
                                  let age = childData["age"] as? Int else { return nil }
                            return Child(id: id, username: username, age: age)
                        }
                    )
                }
            }
            .sheet(isPresented: $showingCreateGame) {
                CreateAIGameView(viewModel: AIGameParentViewModel())
            }
            .alert("Erreur", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.badge.gearshape.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Gestionnaire d'Assignments")
                .font(.title2.weight(.semibold))
            
            Text("Assignez des jeux IA personnalisés à vos enfants et suivez leurs progrès")
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
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Actions Rapides")
                .font(.headline)
            
            HStack(spacing: 12) {
                Button(action: { showingCreateGame = true }) {
                    AssignmentQuickActionCard(
                        icon: "brain.head.profile",
                        title: "Créer Jeu",
                        subtitle: "Nouveau jeu IA",
                        color: .blue
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: AIGameAssignmentHistoryView(viewModel: viewModel)) {
                    AssignmentQuickActionCard(
                        icon: "clock.arrow.circlepath",
                        title: "Historique",
                        subtitle: "Voir tout",
                        color: .green
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var availableGamesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Jeux Disponibles")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.availableGames.count) jeux")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if viewModel.availableGames.isEmpty {
                emptyGamesView
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(viewModel.availableGames) { game in
                        AssignableGameCard(game: game) {
                            viewModel.startAssignment(game: game)
                        }
                    }
                }
            }
        }
    }
    
    private var emptyGamesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("Aucun jeu disponible")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Créez des jeux IA pour commencer à les assigner")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Créer un jeu") {
                showingCreateGame = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var activeAssignmentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Assignments Actifs")
                .font(.headline)
            
            let activeAssignments = viewModel.assignments.filter { 
                $0.status == .assigned || $0.status == .inProgress 
            }
            
            if activeAssignments.isEmpty {
                Text("Aucun assignment actif")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            } else {
                ForEach(activeAssignments.prefix(3)) { assignment in
                    ActiveAssignmentRow(assignment: assignment, viewModel: viewModel)
                }
                
                if activeAssignments.count > 3 {
                    NavigationLink(destination: AIGameAssignmentHistoryView(viewModel: viewModel)) {
                        HStack {
                            Text("Voir tous les assignments (\(activeAssignments.count))")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

struct AssignmentQuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct AssignableGameCard: View {
    let game: GeneratedGame
    let onAssign: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                DomainBadge(domain: game.domain)
                Spacer()
                Text("\(game.durationSeconds / 60)min")
                    .font(.caption)
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
                Text("\(game.recommendedAgeMin)+ ans")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Assigner") {
                    onAssign()
                }
                .font(.caption.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct ActiveAssignmentRow: View {
    let assignment: AIGameAssignmentService.AIGameAssignment
    @ObservedObject var viewModel: AIGameAssignmentViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Jeu assigné")
                    .font(.subheadline.weight(.medium))
                
                Text("Enfant ID: \(assignment.childId)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let dueDate = assignment.dueDate {
                    Text("Échéance: \(dueDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(assignment.status.displayName)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(assignment.status.color.opacity(0.2))
                    .foregroundColor(assignment.status.color)
                    .cornerRadius(4)
                
                Text(assignment.priority.displayName)
                    .font(.caption)
                    .foregroundColor(assignment.priority.color)
            }
            
            Button("Annuler") {
                viewModel.cancelAssignment(assignment)
            }
            .font(.caption)
            .foregroundColor(.red)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    AIGameAssignmentView()
        .environmentObject(AuthViewModel())
}
