import SwiftUI
import Combine

class PuzzleAssignmentViewModel: ObservableObject {
    @Published var children: [Child] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let puzzleService = PuzzleService.shared
    private let childService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    private var parentToken: String = ""
    
    func setParentToken(_ token: String) {
        self.parentToken = token
    }
    
    func loadChildren() {
        isLoading = true
        errorMessage = nil
        
        // TODO: Implémenter le chargement des enfants du parent
        // Pour l'instant, nous utilisons un appel API générique
        print("📚 PuzzleAssignmentViewModel: Loading children...")
        isLoading = false
    }
    
    func createPuzzleForChild(
        childId: String,
        childName: String,
        gridSize: Int,
        completion: @escaping (String) -> Void
    ) {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        // Store the childId for later use
        UserDefaults.standard.set(childId, forKey: "childId")
        
        puzzleService.createPuzzle(
            playerName: childName,
            gridSize: gridSize,
            token: parentToken
        )
        .sink(
            receiveCompletion: { [weak self] result in
                self?.isLoading = false
                if case .failure(let error) = result {
                    self?.errorMessage = "Erreur lors de la création: \(error.localizedDescription)"
                    print("❌ PuzzleAssignmentViewModel: Error - \(error)")
                }
            },
            receiveValue: { [weak self] puzzle in
                self?.successMessage = "✅ Puzzle assigné à \(childName) ! L'enfant peut maintenant le voir dans sa liste."
                print("✅ PuzzleAssignmentViewModel: Puzzle created - ID: \(puzzle.id)")
                print("📝 PuzzleAssignmentViewModel: Stored childId: \(childId)")
                completion(puzzle.id)
            }
        )
        .store(in: &cancellables)
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}
