//
//  ChildPuzzleListViewModel.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 1/12/2025.
//

import SwiftUI
import Combine

class ChildPuzzleListViewModel: ObservableObject {
    @Published var puzzles: [Puzzle] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let puzzleService = PuzzleService.shared
    private var cancellables = Set<AnyCancellable>()
    private var token: String = ""
    
    var completedPuzzles: [Puzzle] {
        puzzles.filter { $0.completed }
    }
    
    var inProgressPuzzles: [Puzzle] {
        puzzles.filter { !$0.completed }
    }
    
    func setToken(_ token: String) {
        self.token = token
        print("🔑 ChildPuzzleListViewModel: Token set")
    }
    
    func loadPuzzles() {
        guard !token.isEmpty else {
            errorMessage = "Token non disponible"
            print("❌ ChildPuzzleListViewModel: No token available")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        print("🎮 ChildPuzzleListViewModel: Loading all available puzzles...")
        
        // Les puzzles sont disponibles pour tous les enfants (pas d'assignation spécifique)
        puzzleService.getAllPuzzles(token: token)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur: \(error.localizedDescription)"
                        print("❌ ChildPuzzleListViewModel: Error loading puzzles - \(error)")
                    }
                },
                receiveValue: { [weak self] puzzles in
                    print("✅ ChildPuzzleListViewModel: Loaded \(puzzles.count) puzzles")
                    self?.puzzles = puzzles
                }
            )
            .store(in: &cancellables)
    }
}
