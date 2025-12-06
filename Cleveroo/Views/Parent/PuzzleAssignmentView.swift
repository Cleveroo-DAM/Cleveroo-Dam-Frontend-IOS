import SwiftUI

struct PuzzleAssignmentView: View {
    @StateObject private var viewModel = PuzzleAssignmentViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedChild: Child?
    @State private var selectedGridSize: Int = 3
    @State private var showGridSizeSelection = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Text("🎮 Assigner un Puzzle")
                            .font(.headline)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Step 1: Select Child
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Étape 1: Sélectionner un enfant")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                
                                if let child = selectedChild {
                                    ChildSelectionCard(child: child, isSelected: true) {
                                        selectedChild = nil
                                    }
                                } else {
                                    Text("Aucun enfant sélectionné")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                }
                                
                                NavigationLink(destination: ChildSelectionListView(selectedChild: $selectedChild)) {
                                    HStack {
                                        Image(systemName: "person.badge.plus")
                                        Text("Choisir un enfant")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(12)
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            
                            // Step 2: Select Grid Size
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Étape 2: Choisir la difficulté")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                
                                VStack(spacing: 12) {
                                    GridSizeOption(
                                        size: 3,
                                        title: "3x3 - Facile",
                                        description: "9 cases",
                                        isSelected: selectedGridSize == 3
                                    ) {
                                        selectedGridSize = 3
                                    }
                                    
                                    GridSizeOption(
                                        size: 4,
                                        title: "4x4 - Moyen",
                                        description: "16 cases",
                                        isSelected: selectedGridSize == 4
                                    ) {
                                        selectedGridSize = 4
                                    }
                                    
                                    GridSizeOption(
                                        size: 5,
                                        title: "5x5 - Difficile",
                                        description: "25 cases",
                                        isSelected: selectedGridSize == 5
                                    ) {
                                        selectedGridSize = 5
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            
                            // Step 3: Assign
                            if selectedChild != nil {
                                Button(action: assignPuzzle) {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                            Text("Assigner le Puzzle")
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .disabled(viewModel.isLoading)
                            } else {
                                HStack {
                                    Image(systemName: "exclamationmark.circle")
                                    Text("Veuillez sélectionner un enfant")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.gray)
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                let token = authViewModel.currentUserToken ?? UserDefaults.standard.string(forKey: "jwt") ?? ""
                viewModel.setParentToken(token)
            }
            .alert("Erreur", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.clearMessages() }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .alert("Succès", isPresented: .constant(viewModel.successMessage != nil)) {
                Button("OK") {
                    viewModel.clearMessages()
                    dismiss()
                }
            } message: {
                if let success = viewModel.successMessage {
                    Text(success)
                }
            }
        }
    }
    
    private func assignPuzzle() {
        guard let child = selectedChild else { return }
        
        viewModel.createPuzzleForChild(
            childId: child.id ?? "",
            childName: child.username,
            gridSize: selectedGridSize
        ) { puzzleId in
            print("✅ Puzzle assigné: \(puzzleId)")
        }
    }
}

// MARK: - Child Selection List
struct ChildSelectionListView: View {
    @Binding var selectedChild: Child?
    @State private var children: [Child] = []
    @State private var isLoading = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                if isLoading {
                    ProgressView()
                } else if children.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Aucun enfant trouvé")
                            .font(.headline)
                    }
                } else {
                    List(children) { child in
                        ChildSelectionCard(child: child, isSelected: selectedChild?.id == child.id) {
                            selectedChild = child
                            dismiss()
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .padding()
        }
        .navigationTitle("Sélectionner un enfant")
        .onAppear {
            loadChildren()
        }
    }
    
    private func loadChildren() {
        // TODO: Implémenter le chargement des enfants du parent
        // Pour l'instant, exemple dummy
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            children = [
                Child(id: "1", username: "Emma", age: 8, gender: "female", avatarURL: "🧒", qrCode: nil),
                Child(id: "2", username: "Luc", age: 6, gender: "male", avatarURL: "👦", qrCode: nil),
            ]
            isLoading = false
        }
    }
}

// MARK: - Child Selection Card
struct ChildSelectionCard: View {
    let child: Child
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(child.avatarURL ?? "👶")
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(child.username)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Âge: \(child.age) ans")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "circle")
                        .font(.title2)
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .padding()
            .background(isSelected ? Color.green.opacity(0.1) : Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Grid Size Option
struct GridSizeOption: View {
    let size: Int
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    ForEach(0..<size, id: \.self) { i in
                        ForEach(0..<size, id: \.self) { j in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 12, height: 12)
                                .offset(x: CGFloat(i - size/2) * 16, y: CGFloat(j - size/2) * 16)
                        }
                    }
                }
                .frame(width: 50, height: 50)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "circle")
                        .font(.title2)
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .padding()
            .background(isSelected ? Color.green.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PuzzleAssignmentView()
        .environmentObject(AuthViewModel())
}
