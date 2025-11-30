//
//  AIGameAssignmentViewModel.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 24/11/2025.
//

import Foundation
import Combine
import SwiftUI

class AIGameAssignmentViewModel: ObservableObject {
    @Published var assignments: [AIGameAssignmentService.AIGameAssignment] = []
    @Published var availableGames: [GeneratedGame] = []
    @Published var selectedChildren: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAssignmentSheet = false
    @Published var selectedGame: GeneratedGame?
    
    // Form fields
    @Published var selectedPriority: AIGameAssignmentService.Priority = .medium
    @Published var dueDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @Published var hasDueDate = true
    @Published var instructions = ""
    
    private let assignmentService = AIGameAssignmentService.shared
    private let aiGameService = AIGameService.shared
    private var cancellables = Set<AnyCancellable>()
    private var parentToken: String = ""
    
    func setParentToken(_ token: String) {
        self.parentToken = token
    }
    
    // MARK: - Load Data
    func loadAvailableGames() {
        isLoading = true
        errorMessage = nil
        
        // Ici nous chargeons les jeux que le parent a créés
        // Pour l'instant, nous utiliserons une approche simplifiée
        // Dans une vraie implémentation, il faudrait un endpoint spécifique
        
        aiGameService.getMyGames(token: parentToken)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors du chargement des jeux: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] response in
                    self?.availableGames = response.games
                }
            )
            .store(in: &cancellables)
    }
    
    func loadAssignments() {
        isLoading = true
        
        assignmentService.getParentAssignments(token: parentToken)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors du chargement des assignments: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] assignments in
                    self?.assignments = assignments
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Assignment Actions
    func startAssignment(game: GeneratedGame) {
        selectedGame = game
        resetForm()
        showingAssignmentSheet = true
    }
    
    func assignGameToSelectedChildren(children: [Child]) {
        guard let game = selectedGame else { return }
        
        isLoading = true
        errorMessage = nil
        
        let group = DispatchGroup()
        var hasError = false
        
        for child in children {
            guard let childId = child.id else { continue }
            
            let request = AIGameAssignmentService.AssignGameRequest(
                childId: childId,
                gameId: game.id,
                dueDate: hasDueDate ? dueDate : nil,
                priority: selectedPriority,
                instructions: instructions.isEmpty ? nil : instructions
            )
            
            group.enter()
            assignmentService.assignGameToChild(request: request, token: parentToken)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure = completion {
                            hasError = true
                        }
                        group.leave()
                    },
                    receiveValue: { [weak self] assignment in
                        self?.assignments.append(assignment)
                    }
                )
                .store(in: &cancellables)
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
            if hasError {
                self?.errorMessage = "Certains assignments ont échoué"
            } else {
                self?.showingAssignmentSheet = false
                self?.selectedGame = nil
            }
        }
    }
    
    func cancelAssignment(_ assignment: AIGameAssignmentService.AIGameAssignment) {
        assignmentService.cancelAssignment(assignmentId: assignment.id, token: parentToken)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors de l'annulation: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] _ in
                    if let index = self?.assignments.firstIndex(where: { $0.id == assignment.id }) {
                        self?.assignments[index] = AIGameAssignmentService.AIGameAssignment(
                            id: assignment.id,
                            childId: assignment.childId,
                            gameId: assignment.gameId,
                            parentId: assignment.parentId,
                            status: .cancelled,
                            dueDate: assignment.dueDate,
                            priority: assignment.priority,
                            instructions: assignment.instructions,
                            estimatedDuration: assignment.estimatedDuration,
                            createdAt: assignment.createdAt,
                            completedAt: assignment.completedAt,
                            score: assignment.score,
                            feedback: assignment.feedback
                        )
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    private func resetForm() {
        selectedPriority = .medium
        dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        hasDueDate = true
        instructions = ""
        selectedChildren.removeAll()
    }
    
    func assignmentsForChild(_ childId: String) -> [AIGameAssignmentService.AIGameAssignment] {
        return assignments.filter { $0.childId == childId }
    }
    
    func activeAssignmentsCount(for childId: String) -> Int {
        return assignmentsForChild(childId).filter { 
            $0.status == .assigned || $0.status == .inProgress 
        }.count
    }
    
    func completedAssignmentsCount(for childId: String) -> Int {
        return assignmentsForChild(childId).filter { $0.status == .completed }.count
    }
}