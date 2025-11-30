//
//  AIGameAssignmentHistoryView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 24/11/2025.
//

import SwiftUI

struct AIGameAssignmentHistoryView: View {
    @ObservedObject var viewModel: AIGameAssignmentViewModel
    @State private var selectedStatus: AIGameAssignmentService.AssignmentStatus? = nil
    @State private var searchText = ""
    
    var filteredAssignments: [AIGameAssignmentService.AIGameAssignment] {
        var assignments = viewModel.assignments
        
        if let status = selectedStatus {
            assignments = assignments.filter { $0.status == status }
        }
        
        if !searchText.isEmpty {
            assignments = assignments.filter { assignment in
                assignment.childId.localizedCaseInsensitiveContains(searchText) ||
                assignment.gameId.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return assignments.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filters and search
            filtersSection
            
            // Assignments list
            if filteredAssignments.isEmpty {
                emptyStateView
            } else {
                assignmentsList
            }
        }
        .navigationTitle("Historique des Assignments")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var filtersSection: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Rechercher par enfant ou jeu...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button("Effacer") {
                        searchText = ""
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Status filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "Tous",
                        isSelected: selectedStatus == nil,
                        color: .gray
                    ) {
                        selectedStatus = nil
                    }
                    
                    ForEach(AIGameAssignmentService.AssignmentStatus.allCases, id: \.self) { status in
                        FilterChip(
                            title: status.displayName,
                            isSelected: selectedStatus == status,
                            color: status.color
                        ) {
                            selectedStatus = selectedStatus == status ? nil : status
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var assignmentsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredAssignments) { assignment in
                    AssignmentHistoryCard(assignment: assignment, viewModel: viewModel)
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Aucun assignment trouvé")
                .font(.title2.weight(.medium))
            
            Text(selectedStatus == nil ?
                 "Vous n'avez pas encore créé d'assignments" :
                 "Aucun assignment avec le statut '\(selectedStatus!.displayName)'"
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            
            if selectedStatus != nil {
                Button("Voir tous les assignments") {
                    selectedStatus = nil
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected ? color.opacity(0.2) : Color(.systemGray6)
                )
                .foregroundColor(
                    isSelected ? color : .primary
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? color : Color.clear,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AssignmentHistoryCard: View {
    let assignment: AIGameAssignmentService.AIGameAssignment
    @ObservedObject var viewModel: AIGameAssignmentViewModel
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Assignment #\(assignment.id.suffix(6))")
                        .font(.headline.weight(.medium))
                    
                    Text("Enfant: \(assignment.childId)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(assignment.status.displayName)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(assignment.status.color.opacity(0.2))
                        .foregroundColor(assignment.status.color)
                        .cornerRadius(8)
                    
                    Text(assignment.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Game info and details
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let dueDate = assignment.dueDate {
                        Label(
                            dueDate > Date() ? "Échéance: \(dueDate, style: .date)" : "En retard depuis: \(dueDate, style: .date)",
                            systemImage: dueDate > Date() ? "clock" : "exclamationmark.triangle"
                        )
                        .font(.caption)
                        .foregroundColor(dueDate > Date() ? .orange : .red)
                    }
                    
                    Label(assignment.priority.displayName, systemImage: "flag.fill")
                        .font(.caption)
                        .foregroundColor(assignment.priority.color)
                }
                
                Spacer()
                
                Button("Détails") {
                    showingDetails = true
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(6)
            }
            
            // Progress indicator for active assignments
            if assignment.status == .inProgress {
                ProgressView(value: 0.3) // Mock progress - you'd get this from backend
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(y: 2)
            }
            
            // Quick actions
            if assignment.status == .assigned || assignment.status == .inProgress {
                HStack(spacing: 12) {
                    Button("Rappel") {
                        // Send reminder notification
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(6)
                    
                    Button("Annuler") {
                        viewModel.cancelAssignment(assignment)
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(6)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showingDetails) {
            AIGameAssignmentDetailView(assignment: assignment)
        }
    }
}

struct AIGameAssignmentDetailView: View {
    let assignment: AIGameAssignmentService.AIGameAssignment
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Assignment overview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Informations de l'Assignment")
                            .font(.headline)
                        
                        AIGameDetailRow(label: "ID", value: assignment.id)
                        AIGameDetailRow(label: "Enfant", value: assignment.childId)
                        AIGameDetailRow(label: "Jeu", value: assignment.gameId)
                        AIGameDetailRow(label: "Statut", value: assignment.status.displayName)
                        AIGameDetailRow(label: "Priorité", value: assignment.priority.displayName)
                        AIGameDetailRow(label: "Créé le", value: assignment.createdAt.formatted())
                        
                        if let dueDate = assignment.dueDate {
                            AIGameDetailRow(label: "Échéance", value: dueDate.formatted())
                        }
                        
                        if let completedAt = assignment.completedAt {
                            AIGameDetailRow(label: "Terminé le", value: completedAt.formatted())
                        }
                    }
                    
                    // Instructions
                    if let instructions = assignment.instructions, !instructions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Instructions")
                                .font(.headline)
                            
                            Text(instructions)
                                .font(.body)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }
                    
                    // Feedback
                    if let feedback = assignment.feedback, !feedback.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Commentaires")
                                .font(.headline)
                            
                            Text(feedback)
                                .font(.body)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Détails Assignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AIGameDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text("\(label):")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationView {
        AIGameAssignmentHistoryView(viewModel: AIGameAssignmentViewModel())
    }
}
