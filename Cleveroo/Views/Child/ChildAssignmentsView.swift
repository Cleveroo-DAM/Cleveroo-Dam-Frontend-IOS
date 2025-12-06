//
//  ChildAssignmentsView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 24/11/2025.
//

import SwiftUI
import Combine
import Foundation

struct ChildAssignmentsView: View {
    @StateObject private var viewModel = ChildAssignmentViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Pending assignments
                    pendingAssignmentsSection
                    
                    // In progress assignments
                    inProgressSection
                    
                    // Completed assignments preview
                    completedPreviewSection
                }
                .padding()
            }
            .navigationTitle("Mes Missions")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if let token = authViewModel.currentUserToken,
                   let childId = authViewModel.currentChildId {
                    viewModel.setChildToken(token)
                    viewModel.setChildId(childId)
                    viewModel.loadAssignments()
                }
            }
            .refreshable {
                viewModel.loadAssignments()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "target")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("🎯 Tes Missions de Jeu")
                .font(.title2.weight(.semibold))
            
            Text("Découvre les jeux que tes parents ont préparés pour toi !")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
    
    private var pendingAssignmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📋 Nouvelles Missions")
                    .font(.headline)
                
                Spacer()
                
                if !viewModel.pendingAssignments.isEmpty {
                    Text("\(viewModel.pendingAssignments.count)")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            
            if viewModel.pendingAssignments.isEmpty {
                Text("Aucune nouvelle mission ! 🎉")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            } else {
                ForEach(viewModel.pendingAssignments) { assignment in
                    ChildAssignmentCard(assignment: assignment, viewModel: viewModel)
                }
            }
        }
    }
    
    private var inProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🚀 En Cours")
                    .font(.headline)
                
                Spacer()
                
                if !viewModel.inProgressAssignments.isEmpty {
                    Text("\(viewModel.inProgressAssignments.count)")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            
            if viewModel.inProgressAssignments.isEmpty {
                Text("Aucun jeu en cours")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            } else {
                ForEach(viewModel.inProgressAssignments) { assignment in
                    ChildAssignmentCard(assignment: assignment, viewModel: viewModel)
                }
            }
        }
    }
    
    private var completedPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("✅ Terminées")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink("Voir tout") {
                    ChildAssignmentHistoryView(viewModel: viewModel)
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            if viewModel.completedAssignments.isEmpty {
                Text("Pas encore de missions terminées")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            } else {
                ForEach(viewModel.completedAssignments.prefix(2)) { assignment in
                    CompletedAssignmentCard(assignment: assignment)
                }
                
                if viewModel.completedAssignments.count > 2 {
                    NavigationLink(destination: ChildAssignmentHistoryView(viewModel: viewModel)) {
                        Text("Voir \(viewModel.completedAssignments.count - 2) autres...")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
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

class ChildAssignmentViewModel: ObservableObject {
    @Published var assignments: [AIGameAssignmentService.AIGameAssignment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let assignmentService = AIGameAssignmentService.shared
    private var childToken: String = ""
    private var childId: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    var pendingAssignments: [AIGameAssignmentService.AIGameAssignment] {
        assignments.filter { $0.status == .assigned }
    }
    
    var inProgressAssignments: [AIGameAssignmentService.AIGameAssignment] {
        assignments.filter { $0.status == .inProgress }
    }
    
    var completedAssignments: [AIGameAssignmentService.AIGameAssignment] {
        assignments.filter { $0.status == .completed }
    }
    
    func setChildToken(_ token: String) {
        self.childToken = token
    }
    
    func setChildId(_ id: String) {
        self.childId = id
    }
    
    func loadAssignments() {
        guard !childId.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        assignmentService.getChildAssignments(childId: childId, token: childToken)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors du chargement: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] assignments in
                    self?.assignments = assignments
                }
            )
            .store(in: &cancellables)
    }
    
    func startAssignment(_ assignment: AIGameAssignmentService.AIGameAssignment) {
        assignmentService.updateAssignmentStatus(
            assignmentId: assignment.id,
            status: .inProgress,
            token: childToken
        )
        .sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = "Erreur: \(error.localizedDescription)"
                }
            },
            receiveValue: { [weak self] updatedAssignment in
                if let index = self?.assignments.firstIndex(where: { $0.id == assignment.id }) {
                    self?.assignments[index] = updatedAssignment
                }
            }
        )
        .store(in: &cancellables)
    }
}

struct ChildAssignmentCard: View {
    let assignment: AIGameAssignmentService.AIGameAssignment
    @ObservedObject var viewModel: ChildAssignmentViewModel
    @State private var showingGameDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with priority and due date
            HStack {
                Text(assignment.priority.displayName)
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(assignment.priority.color.opacity(0.2))
                    .foregroundColor(assignment.priority.color)
                    .cornerRadius(8)
                
                Spacer()
                
                if let dueDate = assignment.dueDate {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Échéance")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text(dueDate, style: .date)
                            .font(.caption.weight(.medium))
                            .foregroundColor(dueDate < Date() ? .red : .orange)
                    }
                }
            }
            
            // Game info
            VStack(alignment: .leading, spacing: 8) {
                Text("🎮 Mission de Jeu")
                    .font(.headline)
                
                if let instructions = assignment.instructions {
                    Text("💬 \(instructions)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                if let duration = assignment.estimatedDuration {
                    Label("⏱️ Environ \(duration) minutes", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button("Voir le Jeu") {
                    showingGameDetails = true
                }
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(8)
                
                if assignment.status == .assigned {
                    Button("Commencer") {
                        viewModel.startAssignment(assignment)
                    }
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                } else {
                    Button("Continuer") {
                        // Navigate to game
                    }
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showingGameDetails) {
            GameDetailsSheet(gameId: assignment.gameId)
        }
    }
}

struct CompletedAssignmentCard: View {
    let assignment: AIGameAssignmentService.AIGameAssignment
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Mission Terminée")
                    .font(.subheadline.weight(.medium))
                
                if let completedAt = assignment.completedAt {
                    Text("Terminée le \(completedAt, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let score = assignment.score {
                    Text("Score: \(Int(score * 100))%")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
}

struct GameDetailsSheet: View {
    let gameId: String
    @Environment(\.dismiss) private var dismiss
    // You would load the game details here
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Détails du Jeu")
                Text("Game ID: \(gameId)")
                // Add game details here
            }
            .navigationTitle("Détails")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
}

struct ChildAssignmentHistoryView: View {
    @ObservedObject var viewModel: ChildAssignmentViewModel
    
    var body: some View {
        List(viewModel.completedAssignments) { assignment in
            CompletedAssignmentCard(assignment: assignment)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .navigationTitle("Historique")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    ChildAssignmentsView()
        .environmentObject(AuthViewModel())
}
