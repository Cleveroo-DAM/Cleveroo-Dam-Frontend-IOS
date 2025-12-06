import SwiftUI
import Combine

struct ChildPuzzleListView: View {
    @StateObject private var viewModel = ChildPuzzleListViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedPuzzle: Puzzle?
    @State private var showPuzzleGame = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "puzzlepiece.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.purple)
                        
                        Text("🧩 Mes Puzzles")
                            .font(.title2.weight(.semibold))
                        
                        Text("Résous les puzzles pour gagner des points !")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Puzzles List
                    if viewModel.isLoading {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Chargement...")
                                .foregroundColor(.secondary)
                        }
                    } else if viewModel.puzzles.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "puzzlepiece")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("Aucun puzzle disponible")
                                .font(.headline)
                            
                            Text("Pas encore de puzzles créés. Reviens bientôt!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.puzzles) { puzzle in
                                    NavigationLink(destination: PuzzleGameView(puzzleId: puzzle.id)) {
                                        PuzzleListCard(puzzle: puzzle)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    
                    // Statistics
                    if !viewModel.puzzles.isEmpty {
                        HStack(spacing: 12) {
                            StatCard(
                                icon: "checkmark.circle.fill",
                                title: "Complétés",
                                value: "\(viewModel.completedPuzzles.count)"
                            )
                            
                            StatCard(
                                icon: "hourglass.end",
                                title: "En cours",
                                value: "\(viewModel.inProgressPuzzles.count)"
                            )
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Puzzles")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                let token = authViewModel.currentUserToken ?? UserDefaults.standard.string(forKey: "jwt") ?? ""
                viewModel.setToken(token)
                viewModel.loadPuzzles()
            }
            .refreshable {
                viewModel.loadPuzzles()
            }
        }
    }
}

// MARK: - Puzzle List Card
struct PuzzleListCard: View {
    let puzzle: Puzzle
    
    var difficultyColor: Color {
        switch puzzle.gridSize {
        case 3: return .green
        case 4: return .orange
        case 5: return .red
        default: return .blue
        }
    }
    
    var difficultyLabel: String {
        switch puzzle.gridSize {
        case 3: return "Facile"
        case 4: return "Moyen"
        case 5: return "Difficile"
        default: return "?\(puzzle.gridSize)x\(puzzle.gridSize)"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🧩 Puzzle \(puzzle.gridSize)x\(puzzle.gridSize)")
                        .font(.headline)
                    
                    Text(difficultyLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if puzzle.completed {
                    VStack(alignment: .trailing, spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                        
                        Text("Complété")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                } else {
                    VStack(alignment: .trailing, spacing: 4) {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                        
                        Text("Jouer")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Divider()
            
            HStack(spacing: 16) {
                InfoBadge(
                    icon: "arrow.left.arrow.right",
                    label: "Mouvements",
                    value: "\(puzzle.moves)"
                )
                
                if let time = puzzle.completionTime {
                    InfoBadge(
                        icon: "clock",
                        label: "Temps",
                        value: formatTime(time)
                    )
                } else {
                    InfoBadge(
                        icon: "calendar",
                        label: "Créé",
                        value: formatDate(puzzle.createdAt ?? Date())
                    )
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Difficulté")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    ForEach(0..<puzzle.gridSize, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(difficultyColor.opacity(0.6))
                            .frame(height: 4)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(difficultyColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: date)
    }
}

// MARK: - Info Badge
struct InfoBadge: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}



#Preview {
    ChildPuzzleListView()
        .environmentObject(AuthViewModel())
}
