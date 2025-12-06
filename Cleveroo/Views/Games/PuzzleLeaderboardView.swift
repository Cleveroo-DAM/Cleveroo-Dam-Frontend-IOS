import SwiftUI
import Combine

struct PuzzleLeaderboardView: View {
    @StateObject private var viewModel = PuzzleLeaderboardViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedGridSize: Int? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.yellow.opacity(0.1), Color.orange.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "podium.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        
                        Text("🏆 Classement")
                            .font(.title2.weight(.semibold))
                        
                        Text("Les meilleurs résolveurs de puzzles !")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Filter Buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            PuzzleFilterButton(
                                title: "Tous",
                                isSelected: selectedGridSize == nil,
                                action: { selectedGridSize = nil }
                            )
                            
                            ForEach([3, 4, 5], id: \.self) { size in
                                PuzzleFilterButton(
                                    title: "\(size)x\(size)",
                                    isSelected: selectedGridSize == size,
                                    action: { selectedGridSize = size }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .scrollIndicators(.never)
                    
                    // Leaderboard
                    if viewModel.isLoading {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Chargement du classement...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxHeight: .infinity)
                    } else if filteredLeaderboard.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "list.dash")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("Aucun score pour cette catégorie")
                                .font(.headline)
                            
                            Text("Sois le premier à résoudre un puzzle !")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(filteredLeaderboard.enumerated()), id: \.element.id) { index, entry in
                                    LeaderboardRowView(entry: entry, rank: index + 1)
                                }
                            }
                            .padding()
                        }
                    }
                    
                    // Your Score (if available)
                    if let myEntry = viewModel.myEntry {
                        HStack(spacing: 16) {
                            Text("📍 Mon score")
                                .font(.headline)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("#\(myEntry.rank)")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(.blue)
                                
                                Text("\(myEntry.moves) mouvements")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Classement")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                let token = authViewModel.currentUserToken ?? UserDefaults.standard.string(forKey: "jwt") ?? ""
                viewModel.setToken(token)
                viewModel.loadLeaderboard()
            }
            .refreshable {
                viewModel.loadLeaderboard()
            }
            .alert("Erreur", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.clearError() }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
    
    private var filteredLeaderboard: [LeaderboardEntry] {
        if let gridSize = selectedGridSize {
            return viewModel.leaderboard.filter { $0.gridSize == gridSize }
        }
        return viewModel.leaderboard
    }
}

// MARK: - Leaderboard Row
struct LeaderboardRowView: View {
    let entry: LeaderboardEntry
    let rank: Int
    
    var medalIcon: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "•"
        }
    }
    
    var backgroundColor: Color {
        switch rank {
        case 1: return .yellow.opacity(0.1)
        case 2: return .gray.opacity(0.1)
        case 3: return .orange.opacity(0.1)
        default: return Color(.systemGray6)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(medalIcon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("#\(rank) - \(entry.playerName)")
                    .font(.headline)
                
                HStack(spacing: 16) {
                    Label("\(entry.moves) mouvements", systemImage: "arrow.left.arrow.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label(formatTime(entry.completionTime), systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("\(entry.gridSize)x\(entry.gridSize)", systemImage: "square.grid.2x2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.0f⭐", Double(entry.moves) > 0 ? 100.0 / Double(entry.moves) : 0))
                    .font(.headline)
                    .foregroundColor(.orange)
                
                if let completedAt = entry.completedAt {
                    Text(formatDate(completedAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    rank <= 3 ? Color.yellow.opacity(0.3) : Color.clear,
                    lineWidth: 1
                )
        )
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
}

// MARK: - Filter Button
struct PuzzleFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.orange : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - ViewModel
class PuzzleLeaderboardViewModel: ObservableObject {
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var myEntry: LeaderboardEntry?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let puzzleService = PuzzleService.shared
    private var token: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    func setToken(_ token: String) {
        self.token = token
    }
    
    func loadLeaderboard() {
        isLoading = true
        errorMessage = nil
        
        puzzleService.getLeaderboard(limit: 50, token: token)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur: \(error.localizedDescription)"
                        print("❌ PuzzleLeaderboardViewModel: Error - \(error)")
                    }
                },
                receiveValue: { [weak self] entries in
                    self?.leaderboard = entries
                    print("✅ PuzzleLeaderboardViewModel: Loaded \(entries.count) entries")
                }
            )
            .store(in: &cancellables)
    }
    
    func clearError() {
        errorMessage = nil
    }
}

#Preview {
    PuzzleLeaderboardView()
        .environmentObject(AuthViewModel())
}
