//
//  AIGameViewModel.swift
//  CleverooDAM
//
//  ViewModel for AI Games with Combine framework
//

import Foundation
import Combine

/// ViewModel managing AI Game state and business logic
@MainActor
public class AIGameViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var availableGames: [AIGame] = []
    @Published public var currentGame: AIGame?
    @Published public var currentSession: AIGameSession?
    @Published public var currentLevel: GameLevel?
    @Published public var currentChallenge: Challenge?
    @Published public var userAnswer: String = ""
    @Published public var score: Int = 0
    @Published public var isLoading: Bool = false
    @Published public var error: String?
    @Published public var gameState: GameState = .browsing
    @Published public var hintsUsed: Int = 0
    @Published public var availableHints: [String] = []
    @Published public var showFeedback: Bool = false
    @Published public var feedbackMessage: String = ""
    @Published public var lastAnswerCorrect: Bool = false
    
    // MARK: - Game State
    
    public enum GameState {
        case browsing
        case loading
        case playing
        case challengeCompleted
        case levelCompleted
        case gameCompleted
        case error
    }
    
    // MARK: - Properties
    
    private let service: AIGamesService
    private let childId: String
    private var cancellables = Set<AnyCancellable>()
    private var challengeStartTime: Date?
    private var currentChallengeIndex: Int = 0
    
    // MARK: - Initialization
    
    public init(childId: String, service: AIGamesService = AIGamesService()) {
        self.childId = childId
        self.service = service
    }
    
    // MARK: - Game Discovery
    
    /// Load available games
    /// - Parameters:
    ///   - gameType: Optional filter by game type
    ///   - difficulty: Optional filter by difficulty
    public func loadGames(gameType: AIGame.GameType? = nil, difficulty: AIGame.Difficulty? = nil) {
        isLoading = true
        error = nil
        
        service.listGames(gameType: gameType, difficulty: difficulty)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                    self?.gameState = .error
                }
            }, receiveValue: { [weak self] games in
                self?.availableGames = games
            })
            .store(in: &cancellables)
    }
    
    /// Generate a new AI game
    /// - Parameters:
    ///   - gameType: Type of game to generate
    ///   - difficulty: Difficulty level
    ///   - ageRange: Target age range
    public func generateGame(gameType: AIGame.GameType, difficulty: AIGame.Difficulty, ageRange: AIGame.AgeRange) {
        isLoading = true
        error = nil
        gameState = .loading
        
        let request = GenerateGameRequest(
            childId: childId,
            gameType: gameType,
            difficulty: difficulty,
            ageRange: ageRange
        )
        
        service.generateGame(request: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                    self?.gameState = .error
                }
            }, receiveValue: { [weak self] game in
                self?.currentGame = game
                self?.availableGames.append(game)
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Session Management
    
    /// Start a game session
    /// - Parameter game: The game to start
    public func startGame(_ game: AIGame) {
        isLoading = true
        error = nil
        currentGame = game
        
        let request = StartGameSessionRequest(gameId: game.id, childId: childId)
        
        service.startSession(request: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                    self?.gameState = .error
                }
            }, receiveValue: { [weak self] session in
                self?.currentSession = session
                self?.score = session.score
                self?.gameState = .playing
                self?.trackEvent(.gameStarted)
                self?.loadCurrentLevel()
            })
            .store(in: &cancellables)
    }
    
    /// Load the current level
    private func loadCurrentLevel() {
        guard let game = currentGame,
              let session = currentSession else { return }
        
        let levelIndex = session.currentLevel - 1
        guard levelIndex < game.content.levels.count else {
            completeGame()
            return
        }
        
        currentLevel = game.content.levels[levelIndex]
        currentChallengeIndex = 0
        loadCurrentChallenge()
        trackEvent(.levelStarted, data: ["level": "\(session.currentLevel)"])
    }
    
    /// Load the current challenge
    private func loadCurrentChallenge() {
        guard let level = currentLevel else { return }
        
        guard currentChallengeIndex < level.challenges.count else {
            completeLevel()
            return
        }
        
        currentChallenge = level.challenges[currentChallengeIndex]
        availableHints = currentChallenge?.hints ?? []
        hintsUsed = 0
        userAnswer = ""
        showFeedback = false
        challengeStartTime = Date()
    }
    
    /// Submit answer for current challenge
    public func submitAnswer() {
        guard let sessionId = currentSession?.id,
              let challengeId = currentChallenge?.id,
              let startTime = challengeStartTime else {
            return
        }
        
        isLoading = true
        error = nil
        
        let timeSpent = Date().timeIntervalSince(startTime)
        
        let request = SubmitChallengeRequest(
            sessionId: sessionId,
            challengeId: challengeId,
            answer: userAnswer,
            timeSpent: timeSpent,
            hintsUsed: hintsUsed
        )
        
        service.submitChallenge(request: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                    self?.gameState = .error
                }
            }, receiveValue: { [weak self] response in
                self?.handleChallengeResponse(response)
            })
            .store(in: &cancellables)
    }
    
    /// Show a hint for the current challenge
    public func showHint() {
        guard hintsUsed < availableHints.count else { return }
        hintsUsed += 1
        trackEvent(.hintRequested, data: ["hintsUsed": "\(hintsUsed)"])
    }
    
    /// End the current session
    public func endSession() {
        guard let sessionId = currentSession?.id else { return }
        
        isLoading = true
        trackEvent(.gameAbandoned)
        
        service.endSession(sessionId: sessionId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            }, receiveValue: { [weak self] session in
                self?.currentSession = session
                self?.reset()
            })
            .store(in: &cancellables)
    }
    
    /// Reset to browsing state
    public func reset() {
        currentGame = nil
        currentSession = nil
        currentLevel = nil
        currentChallenge = nil
        userAnswer = ""
        score = 0
        hintsUsed = 0
        availableHints = []
        showFeedback = false
        feedbackMessage = ""
        error = nil
        gameState = .browsing
        currentChallengeIndex = 0
    }
    
    // MARK: - Private Methods
    
    private func handleChallengeResponse(_ response: SubmitChallengeResponse) {
        score = response.totalScore
        lastAnswerCorrect = response.isCorrect
        feedbackMessage = response.feedback
        showFeedback = true
        gameState = .challengeCompleted
        
        trackEvent(.challengeCompleted, data: [
            "isCorrect": "\(response.isCorrect)",
            "points": "\(response.pointsEarned)"
        ])
        
        // Auto-advance after feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Timing.aiGameFeedbackDuration) { [weak self] in
            self?.currentChallengeIndex += 1
            self?.loadCurrentChallenge()
        }
    }
    
    private func completeLevel() {
        gameState = .levelCompleted
        trackEvent(.levelCompleted, data: ["level": "\(currentSession?.currentLevel ?? 0)"])
        
        // Move to next level
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Timing.levelTransitionDuration) { [weak self] in
            guard let self = self, var session = self.currentSession else { return }
            session.currentLevel += 1
            self.currentSession = session
            self.loadCurrentLevel()
        }
    }
    
    private func completeGame() {
        gameState = .gameCompleted
        currentSession?.isCompleted = true
        trackEvent(.gameCompleted, data: ["finalScore": "\(score)"])
        
        if let sessionId = currentSession?.id {
            service.endSession(sessionId: sessionId)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] session in
                    self?.currentSession = session
                })
                .store(in: &cancellables)
        }
    }
    
    private func trackEvent(_ eventType: GameEvent.EventType, data: [String: String] = [:]) {
        guard let sessionId = currentSession?.id else { return }
        
        let request = TrackEventRequest(sessionId: sessionId, eventType: eventType, data: data)
        
        service.trackEvent(request: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Properties
    
    public var currentHint: String? {
        guard hintsUsed > 0, hintsUsed <= availableHints.count else { return nil }
        return availableHints[hintsUsed - 1]
    }
    
    public var progressPercentage: Double {
        guard let level = currentLevel, !level.challenges.isEmpty else { return 0 }
        return (Double(currentChallengeIndex) / Double(level.challenges.count)) * 100
    }
}
