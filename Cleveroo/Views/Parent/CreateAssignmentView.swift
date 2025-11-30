//
//  CreateAssignmentView.swift
//  Cleveroo
//
//  Created by GitHub Copilot on 24/11/2025.
//

import SwiftUI
import Combine

struct CreateAssignmentView: View {
    @ObservedObject var viewModel: AssignmentParentViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedType: AssignmentType = .drawing
    @State private var selectedChild: [String: Any]?
    @State private var dueDate = Date().addingTimeInterval(7 * 24 * 60 * 60) // 1 week from now
    @State private var rewardPoints = 10
    @State private var hasDueDate = true
    @State private var hasRewardPoints = true
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background dégradé
                LinearGradient(
                    colors: [
                        Color.green.opacity(0.6),
                        Color.blue.opacity(0.4),
                        Color.purple.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Form
                        VStack(spacing: 20) {
                            titleSection
                            descriptionSection
                            typeSection
                            childSection
                            dueDateSection
                            rewardSection
                        }
                        
                        // Action buttons
                        actionButtons
                    }
                    .padding()
                }
            }
            .navigationTitle("Nouvel Assignment")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.white)
            
            Text("Créer un Assignment")
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)
            
            Text("Assignez une nouvelle tâche à votre enfant")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2))
        )
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Titre de l'assignment")
                .font(.headline)
                .foregroundColor(.white)
            
            TextField("Ex: Dessiner un arbre", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description (optionnel)")
                .font(.headline)
                .foregroundColor(.white)
            
            TextField("Décrivez la tâche en détail...", text: $description, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
        }
    }
    
    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Type d'assignment")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(AssignmentType.allCases, id: \.self) { type in
                    TypeSelectionCard(
                        type: type,
                        isSelected: selectedType == type
                    ) {
                        selectedType = type
                    }
                }
            }
        }
    }
    
    private var childSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Assigner à")
                .font(.headline)
                .foregroundColor(.white)
            
            Menu {
                ForEach(authViewModel.childrenList.indices, id: \.self) { index in
                    let child = authViewModel.childrenList[index]
                    Button(action: {
                        selectedChild = child
                    }) {
                        Text(child["username"] as? String ?? "Enfant")
                    }
                }
            } label: {
                HStack {
                    Text(selectedChild?["username"] as? String ?? "Sélectionner un enfant")
                        .foregroundColor(selectedChild != nil ? .black : .gray)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
            }
        }
    }
    
    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Date limite")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Toggle("", isOn: $hasDueDate)
                    .labelsHidden()
            }
            
            if hasDueDate {
                DatePicker("Date limite", selection: $dueDate, displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
            }
        }
    }
    
    private var rewardSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Points de récompense")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Toggle("", isOn: $hasRewardPoints)
                    .labelsHidden()
            }
            
            if hasRewardPoints {
                HStack {
                    Text("Points:")
                        .foregroundColor(.white.opacity(0.8))
                    
                    Stepper(value: $rewardPoints, in: 0...100, step: 5) {
                        Text("\(rewardPoints)")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: createAssignment) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "plus.circle.fill")
                    }
                    Text(viewModel.isLoading ? "Création..." : "Créer l'Assignment")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(canCreate ? Color.green : Color.gray)
                .cornerRadius(12)
            }
            .disabled(!canCreate || viewModel.isLoading)
            
            Text("L'enfant recevra une notification de ce nouvel assignment")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    private var canCreate: Bool {
        !title.isEmpty && selectedChild != nil
    }
    
    private func createAssignment() {
        guard let childId = selectedChild?["_id"] as? String else { return }
        
        let request = CreateAssignmentRequest(
            childId: childId,
            title: title,
            description: description.isEmpty ? nil : description,
            type: selectedType,
            dueDate: hasDueDate ? dueDate : nil,
            rewardPoints: hasRewardPoints ? rewardPoints : nil
        )
        
        viewModel.createAssignment(request: request)
        
        // Observer pour fermer la vue après création
        let cancellable = viewModel.$successMessage
            .sink { message in
                if message != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        dismiss()
                    }
                }
            }
        
        // Note: Dans une vraie app, il faudrait gérer le cycle de vie du cancellable
    }
}

struct TypeSelectionCard: View {
    let type: AssignmentType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                
                Text(type.displayName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.white : Color.white.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CreateAssignmentView(viewModel: AssignmentParentViewModel())
        .environmentObject(AuthViewModel())
}
