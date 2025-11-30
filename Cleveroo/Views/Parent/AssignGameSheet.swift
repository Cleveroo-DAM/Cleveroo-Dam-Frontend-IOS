//
//  AssignGameSheet.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 24/11/2025.
//

import SwiftUI

struct AssignGameSheet: View {
    let game: GeneratedGame
    @ObservedObject var viewModel: AIGameAssignmentViewModel
    let children: [Child]
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedChildrenIds: Set<String> = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Game preview
                    gamePreviewSection
                    
                    // Select children
                    childrenSelectionSection
                    
                    // Assignment configuration
                    configurationSection
                    
                    // Assignment button
                    assignmentButtonSection
                }
                .padding()
            }
            .navigationTitle("Assigner le Jeu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var gamePreviewSection: some View {
        VStack(spacing: 12) {
            Text("Jeu à Assigner")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        DomainBadge(domain: game.domain)
                        Spacer()
                        Text("\(game.durationSeconds / 60) min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(game.title)
                        .font(.title3.weight(.semibold))
                        .lineLimit(2)
                    
                    if let description = game.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                    
                    Text("Âge recommandé: \(game.recommendedAgeMin)+ ans")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
        }
    }
    
    private var childrenSelectionSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Sélectionner les Enfants")
                    .font(.headline)
                
                Spacer()
                
                if !selectedChildrenIds.isEmpty {
                    Text("\(selectedChildrenIds.count) sélectionné(s)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            if children.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "person.2.slash")
                        .font(.title)
                        .foregroundColor(.gray)
                    
                    Text("Aucun enfant trouvé")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Ajoutez des enfants à votre compte d'abord")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                VStack(spacing: 8) {
                    ForEach(children) { child in
                        ChildSelectionRow(
                            child: child,
                            isSelected: selectedChildrenIds.contains(child.id ?? ""),
                            onToggle: { childId in
                                if selectedChildrenIds.contains(childId) {
                                    selectedChildrenIds.remove(childId)
                                } else {
                                    selectedChildrenIds.insert(childId)
                                }
                            }
                        )
                    }
                }
            }
        }
    }
    
    private var configurationSection: some View {
        VStack(spacing: 16) {
            Text("Configuration de l'Assignment")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Priority selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Priorité")
                    .font(.subheadline.weight(.medium))
                
                HStack(spacing: 12) {
                    ForEach(AIGameAssignmentService.Priority.allCases, id: \.self) { priority in
                        Button(action: {
                            viewModel.selectedPriority = priority
                        }) {
                            Text(priority.displayName)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    viewModel.selectedPriority == priority ?
                                    priority.color.opacity(0.2) :
                                    Color(.systemGray6)
                                )
                                .foregroundColor(
                                    viewModel.selectedPriority == priority ?
                                    priority.color :
                                    .primary
                                )
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            viewModel.selectedPriority == priority ?
                                            priority.color :
                                            Color.clear,
                                            lineWidth: 1
                                        )
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            // Due date toggle and picker
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Définir une échéance", isOn: $viewModel.hasDueDate)
                    .font(.subheadline.weight(.medium))
                
                if viewModel.hasDueDate {
                    DatePicker(
                        "Date d'échéance",
                        selection: $viewModel.dueDate,
                        in: Date()...,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(CompactDatePickerStyle())
                }
            }
            
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                Text("Instructions (optionnel)")
                    .font(.subheadline.weight(.medium))
                
                TextField(
                    "Ex: Concentre-toi bien sur les questions de logique...",
                    text: $viewModel.instructions,
                    axis: .vertical
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
            }
        }
    }
    
    private var assignmentButtonSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                let selectedChildren = children.filter { child in
                    selectedChildrenIds.contains(child.id ?? "")
                }
                viewModel.assignGameToSelectedChildren(children: selectedChildren)
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                    
                    Text(viewModel.isLoading ? "Assignment en cours..." : "Assigner le Jeu")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    selectedChildrenIds.isEmpty || viewModel.isLoading ?
                    Color.gray :
                    Color.blue
                )
                .cornerRadius(12)
            }
            .disabled(selectedChildrenIds.isEmpty || viewModel.isLoading)
            
            if !selectedChildrenIds.isEmpty {
                Text("Le jeu sera assigné à \(selectedChildrenIds.count) enfant(s)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top)
    }
}

struct ChildSelectionRow: View {
    let child: Child
    let isSelected: Bool
    let onToggle: (String) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                if let childId = child.id {
                    onToggle(childId)
                }
            }) {
                HStack(spacing: 12) {
                    // Avatar
                    Circle()
                        .fill(isSelected ? Color.blue.opacity(0.3) : Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(child.username.prefix(1).uppercased()))
                                .font(.headline.weight(.bold))
                                .foregroundColor(isSelected ? .blue : .gray)
                        )
                    
                    // Child info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(child.username)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primary)
                        
                        Text("\(child.age) ans")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Selection indicator
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(isSelected ? .blue : .gray)
                }
                .padding()
                .background(
                    isSelected ?
                    Color.blue.opacity(0.1) :
                    Color(.systemGray6)
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? Color.blue : Color.clear,
                            lineWidth: 1
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    AssignGameSheet(
        game: GeneratedGame(
            id: "1",
            title: "Jeu de Personnalité",
            description: "Un jeu pour découvrir ta personnalité",
            domain: "personality",
            recommendedAgeMin: 6,
            recommendedAgeMax: 10,
            durationSeconds: 300,
            spec: GameSpec(steps: [], metadata: nil),
            meta: nil
        ),
        viewModel: AIGameAssignmentViewModel(),
        children: [
            Child(id: "1", username: "Alice", age: 8),
            Child(id: "2", username: "Bob", age: 10)
        ]
    )
}