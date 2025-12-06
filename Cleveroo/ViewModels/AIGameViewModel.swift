//
//  AIGameViewModel.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 24/11/2025.
//

import Foundation
import Combine
import SwiftUI

class AIGameViewModel: ObservableObject {
    @Published var availableGames: [GeneratedGame] = []
    @Published var currentSession: GameSession?
    @Published var currentGame: GeneratedGame?
    @Published var currentStepIndex = 0
    @Published var sessionEvents: [GameEvent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var sessionProgress: SessionProgress?
    @Published var isGameCompleted = false
    @Published var finalReport: PersonalityResult?
    
    private let aiGameService = AIGameService.shared
    private var cancellables = Set<AnyCancellable>()
    private var userToken: String = ""
    
    // MARK: - Session Management (New Session View)
    
    func startSession(token: String, gameId: String, completion: @escaping (Bool, String?) -> Void) {
        self.userToken = token
        isLoading = true
        errorMessage = nil
        
        aiGameService.startSession(gameId: gameId, token: token)
            .sink(
                receiveCompletion: { [weak self] completion_inner in
                    self?.isLoading = false
                    if case .failure(let error) = completion_inner {
                        self?.errorMessage = "Erreur: \(error.localizedDescription)"
                        completion(false, nil)
                    }
                },
                receiveValue: { [weak self] response in
                    self?.currentSession = response.session
                    self?.currentGame = response.game
                    completion(true, response.session.id)
                }
            )
            .store(in: &cancellables)
    }
    
    func pushEvents(sessionId: String, events: [[String: Any]]) {
        // Convert dictionary format to GameEvent format
        let gameEvents = events.compactMap { eventDict -> GameEvent? in
            guard let type = eventDict["type"] as? String,
                  let stepId = eventDict["stepId"] as? String,
                  let payload = eventDict["payload"] as? [String: Any] else {
                return nil
            }
            
            let rt = payload["rt"] as? Double
            let answer = payload["answer"] as? String
            let correct = payload["correct"] as? Bool
            
            return GameEvent(
                type: type,
                stepId: stepId,
                timestamp: Date(),
                payload: EventPayload(
                    answer: answer,
                    correct: correct,
                    rt: rt,
                    choice: answer,
                    accuracy: nil
                )
            )
        }
        
        sessionEvents.append(contentsOf: gameEvents)
        
        aiGameService.pushEvents(sessionId: sessionId, events: gameEvents)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ Erreur lors de l'envoi des événements: \(error)")
                    }
                },
                receiveValue: { [weak self] response in
                    self?.sessionProgress = response.progress
                }
            )
            .store(in: &cancellables)
    }
    
    func completeSession(token: String, sessionId: String, completion: @escaping (Bool, Any?) -> Void) {
        aiGameService.completeSession(sessionId: sessionId, token: token)
            .sink(
                receiveCompletion: { completion_inner in
                    if case .failure(let error) = completion_inner {
                        print("❌ Erreur: \(error)")
                        completion(false, nil)
                    }
                },
                receiveValue: { [weak self] result in
                    self?.isGameCompleted = true
                    completion(true, result)
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func loadAvailableGames(token: String) {
        self.userToken = token
        isLoading = true
        errorMessage = nil
        
        aiGameService.getMyGames(token: token)
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
    
    func startNewGame(_ game: GeneratedGame) {
        isLoading = true
        errorMessage = nil
        currentGame = game
        currentStepIndex = 0
        sessionEvents = []
        isGameCompleted = false
        finalReport = nil
        
        aiGameService.startSession(gameId: game.id, token: userToken)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors du démarrage du jeu: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] response in
                    self?.currentSession = response.session
                    self?.currentGame = response.game
                }
            )
            .store(in: &cancellables)
    }
    
    func submitAnswer(stepId: String, answer: String, isCorrect: Bool? = nil, reactionTime: Double? = nil) {
        guard let session = currentSession else { return }
        
        let event = GameEvent(
            type: "answer",
            stepId: stepId,
            timestamp: Date(),
            payload: EventPayload(
                answer: answer,
                correct: isCorrect,
                rt: reactionTime,
                choice: answer,
                accuracy: nil
            )
        )
        
        sessionEvents.append(event)
        
        // Envoyer l'événement au backend
        aiGameService.pushEvents(sessionId: session.id, events: [event])
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Erreur lors de l'envoi de l'événement: \(error)")
                    }
                },
                receiveValue: { [weak self] response in
                    self?.sessionProgress = response.progress
                }
            )
            .store(in: &cancellables)
        
        // Passer à l'étape suivante
        nextStep()
    }
    
    func submitChoice(stepId: String, choice: String) {
        submitAnswer(stepId: stepId, answer: choice)
    }
    
    func submitReaction(stepId: String, reactionTime: Double, accuracy: Double? = nil) {
        guard let session = currentSession else { return }
        
        let event = GameEvent(
            type: "reaction",
            stepId: stepId,
            timestamp: Date(),
            payload: EventPayload(
                answer: nil,
                correct: nil,
                rt: reactionTime,
                choice: nil,
                accuracy: accuracy
            )
        )
        
        sessionEvents.append(event)
        
        aiGameService.pushEvents(sessionId: session.id, events: [event])
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Erreur lors de l'envoi de la réaction: \(error)")
                    }
                },
                receiveValue: { [weak self] response in
                    self?.sessionProgress = response.progress
                }
            )
            .store(in: &cancellables)
        
        nextStep()
    }
    
    private func nextStep() {
        guard let game = currentGame else { return }
        
        if currentStepIndex < game.spec.steps.count - 1 {
            currentStepIndex += 1
        } else {
            // Jeu terminé
            completeGame()
        }
    }
    
    private func completeGame() {
        guard let session = currentSession else { return }
        
        isLoading = true
        
        aiGameService.completeSession(sessionId: session.id, token: userToken)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors de la finalisation: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] result in
                    self?.finalReport = result
                    self?.isGameCompleted = true
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Properties
    
    var currentStep: GameStep? {
        guard let game = currentGame,
              currentStepIndex < game.spec.steps.count else {
            return nil
        }
        return game.spec.steps[currentStepIndex]
    }
    
    var progressPercentage: Double {
        guard let game = currentGame else { return 0 }
        let totalSteps = game.spec.steps.count
        guard totalSteps > 0 else { return 0 }
        return Double(currentStepIndex) / Double(totalSteps) * 100
    }
    
    var estimatedTimeRemaining: Int {
        guard let game = currentGame else { return 0 }
        let totalSteps = game.spec.steps.count
        let remainingSteps = totalSteps - currentStepIndex
        let avgTimePerStep = game.durationSeconds / totalSteps
        return remainingSteps * avgTimePerStep
    }
}

// MARK: - Parent Dashboard ViewModel
class AIGameParentViewModel: ObservableObject {
    @Published var childProgress: [String: ChildProgressResponse] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var availableDomains = ["personality", "creativity", "attention", "social"]
    @Published var generatedGames: [GeneratedGame] = []
    
    private let aiGameService = AIGameService.shared
    private var cancellables = Set<AnyCancellable>()
    private var parentToken: String = ""
    
    func setParentToken(_ token: String) {
        self.parentToken = token
    }
    
    func generateNewGame(request: GenerateGameRequest) {
        isLoading = true
        errorMessage = nil
        
        aiGameService.generateGame(request: request, token: parentToken)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors de la génération: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] game in
                    self?.generatedGames.append(game)
                }
            )
            .store(in: &cancellables)
    }
    
    func loadChildProgress(childId: String) {
        isLoading = true
        
        aiGameService.getChildProgress(childId: childId, token: parentToken)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors du chargement des progrès: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] progress in
                    self?.childProgress[childId] = progress
                }
            )
            .store(in: &cancellables)
    }
    
    func getSessionReport(sessionId: String) -> AnyPublisher<PersonalityResult, Error> {
        return aiGameService.getSessionReport(sessionId: sessionId, token: parentToken)
    }
}
