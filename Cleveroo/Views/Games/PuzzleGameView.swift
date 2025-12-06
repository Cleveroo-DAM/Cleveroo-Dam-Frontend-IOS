import SwiftUI

struct PuzzleGameView: View {
    @StateObject private var viewModel = PuzzleGameViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    let puzzleId: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
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
                    
                    VStack(spacing: 4) {
                        Text("🎮 Puzzle Game")
                            .font(.headline)
                        Text("Taille: \(viewModel.puzzle?.gridSize ?? 3)x\(viewModel.puzzle?.gridSize ?? 3)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text(formatTime(viewModel.elapsedTime))
                            .font(.headline)
                            .foregroundColor(.orange)
                        Text("Mouvements: \(viewModel.puzzle?.moves ?? 0)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
                // Puzzle Grid
                if let puzzle = viewModel.puzzle {
                    VStack(spacing: 8) {
                        ForEach(0..<puzzle.gridSize, id: \.self) { row in
                            HStack(spacing: 8) {
                                ForEach(0..<puzzle.gridSize, id: \.self) { col in
                                    PuzzleTileView(
                                        number: puzzle.board[row][col],
                                        isEmpty: puzzle.board[row][col] == 0,
                                        isAdjacent: isAdjacentToEmpty(row, col, puzzle),
                                        onTap: {
                                            if isAdjacentToEmpty(row, col, puzzle) {
                                                let token = authViewModel.currentUserToken ?? UserDefaults.standard.string(forKey: "jwt") ?? ""
                                                viewModel.moveTile(row: row, col: col, token: token)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 4)
                } else if viewModel.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Chargement du puzzle...")
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 300)
                }
                
                // Statistics
                if let puzzle = viewModel.puzzle {
                    HStack(spacing: 16) {
                        StatBox(
                            title: "Mouvements",
                            value: "\(puzzle.moves)",
                            icon: "arrow.left.arrow.right"
                        )
                        
                        StatBox(
                            title: "Temps",
                            value: formatTime(viewModel.elapsedTime),
                            icon: "clock"
                        )
                        
                        StatBox(
                            title: "État",
                            value: puzzle.completed ? "✅ Complété" : "⏳ En cours",
                            icon: "checkmark.circle"
                        )
                    }
                }
                
                Spacer()
                
                // Action Buttons
                if let puzzle = viewModel.puzzle {
                    if puzzle.completed {
                        VStack(spacing: 12) {
                            Text("🎉 Félicitations !")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.green)
                            
                            Text("Puzzle complété en \(puzzle.moves) mouvements et \(formatTime(viewModel.elapsedTime))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                let token = authViewModel.currentUserToken ?? UserDefaults.standard.string(forKey: "jwt") ?? ""
                                viewModel.resetPuzzle(token: token)
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Rejouer")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    } else {
                        Button(action: {
                            let token = authViewModel.currentUserToken ?? UserDefaults.standard.string(forKey: "jwt") ?? ""
                            viewModel.resetPuzzle(token: token)
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Réinitialiser")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            let token = authViewModel.currentUserToken ?? UserDefaults.standard.string(forKey: "jwt") ?? ""
            viewModel.loadPuzzle(puzzleId: puzzleId, token: token)
        }
        .alert("Erreur", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.clearMessages() }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .alert("Succès", isPresented: .constant(viewModel.successMessage != nil)) {
            Button("OK") { viewModel.clearMessages() }
        } message: {
            if let success = viewModel.successMessage {
                Text(success)
            }
        }
    }
    
    private func isAdjacentToEmpty(_ row: Int, _ col: Int, _ puzzle: Puzzle) -> Bool {
        guard let emptyPos = puzzle.emptyPosition else { return false }
        
        let isAdjacent = (abs(row - emptyPos.row) == 1 && col == emptyPos.col) ||
                         (abs(col - emptyPos.col) == 1 && row == emptyPos.row)
        return isAdjacent
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
}

// MARK: - Puzzle Tile Component
struct PuzzleTileView: View {
    let number: Int
    let isEmpty: Bool
    let isAdjacent: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isEmpty ? Color(.systemGray6) :
                        isAdjacent ? Color.blue.opacity(0.3) :
                        Color.blue.opacity(0.1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isEmpty ? Color.clear :
                                isAdjacent ? Color.blue : Color.gray.opacity(0.3),
                                lineWidth: 2
                            )
                    )
                
                if !isEmpty {
                    Text("\(number)")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .disabled(isEmpty || !isAdjacent)
        .opacity(isEmpty ? 0.3 : 1)
    }
}

// MARK: - Statistics Box
struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    PuzzleGameView(puzzleId: "test-id")
        .environmentObject(AuthViewModel())
}
