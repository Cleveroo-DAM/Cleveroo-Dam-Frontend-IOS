import SwiftUI
import Combine

class PuzzleGameViewModel: ObservableObject {
    @Published var puzzle: Puzzle?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var elapsedTime: Int = 0
    @Published var isCompleted = false
    
    private let puzzleService = PuzzleService.shared
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var startTime: Date?
    
    func loadPuzzle(puzzleId: String, token: String) {
        isLoading = true
        errorMessage = nil
        
        puzzleService.getPuzzle(puzzleId: puzzleId, token: token)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] puzzle in
                    self?.puzzle = puzzle
                    self?.isCompleted = puzzle.completed
                    if !puzzle.completed {
                        self?.startTimer()
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func moveTile(row: Int, col: Int, token: String) {
        guard let puzzle = puzzle else { return }
        
        isLoading = true
        errorMessage = nil
        
        puzzleService.moveTile(puzzleId: puzzle.id, row: row, col: col, token: token)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] updatedPuzzle in
                    self?.puzzle = updatedPuzzle
                    
                    if updatedPuzzle.completed {
                        self?.stopTimer()
                        self?.isCompleted = true
                        self?.successMessage = updatedPuzzle.message ?? "🎉 Puzzle complété !"
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func resetPuzzle(token: String) {
        guard let puzzle = puzzle else { return }
        
        isLoading = true
        errorMessage = nil
        
        puzzleService.resetPuzzle(puzzleId: puzzle.id, token: token)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] resetPuzzle in
                    self?.puzzle = resetPuzzle
                    self?.isCompleted = false
                    self?.elapsedTime = 0
                    self?.startTimer()
                    self?.successMessage = resetPuzzle.message
                }
            )
            .store(in: &cancellables)
    }
    
    private func startTimer() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let startTime = self?.startTime else { return }
            self?.elapsedTime = Int(Date().timeIntervalSince(startTime))
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
    
    deinit {
        stopTimer()
    }
}
