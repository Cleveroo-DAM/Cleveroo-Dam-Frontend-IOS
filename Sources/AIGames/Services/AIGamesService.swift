//
//  AIGamesService.swift
//  CleverooDAM
//
//  Service layer for AI Games API communication
//

import Foundation
import Combine

/// Service for AI Games operations
public class AIGamesService {
    
    // MARK: - Properties
    
    private let apiClient: APIClient
    
    // MARK: - Initialization
    
    public init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    // MARK: - Game Management
    
    /// List available AI games
    /// - Parameters:
    ///   - gameType: Optional filter by game type
    ///   - difficulty: Optional filter by difficulty
    /// - Returns: Publisher with array of games
    public func listGames(gameType: AIGame.GameType? = nil, difficulty: AIGame.Difficulty? = nil) -> AnyPublisher<[AIGame], APIError> {
        return apiClient.request(
            endpoint: APIClient.AIGamesEndpoint.listGames(
                gameType: gameType?.rawValue,
                difficulty: difficulty?.rawValue
            ).path,
            method: .get
        )
    }
    
    /// Get a specific game by ID
    /// - Parameter gameId: Game identifier
    /// - Returns: Publisher with game details
    public func getGame(gameId: String) -> AnyPublisher<AIGame, APIError> {
        return apiClient.request(
            endpoint: APIClient.AIGamesEndpoint.getGame(gameId: gameId).path,
            method: .get
        )
    }
    
    /// Generate a new AI game
    /// - Parameter request: Game generation request with preferences
    /// - Returns: Publisher with the generated game
    public func generateGame(request: GenerateGameRequest) -> AnyPublisher<AIGame, APIError> {
        return apiClient.request(
            endpoint: APIClient.AIGamesEndpoint.generateGame.path,
            method: .post,
            body: request
        )
    }
    
    // MARK: - Session Management
    
    /// Start a new game session
    /// - Parameter request: Session start request with game and child IDs
    /// - Returns: Publisher with the created session
    public func startSession(request: StartGameSessionRequest) -> AnyPublisher<AIGameSession, APIError> {
        return apiClient.request(
            endpoint: APIClient.AIGamesEndpoint.startSession.path,
            method: .post,
            body: request
        )
    }
    
    /// Get a specific session by ID
    /// - Parameter sessionId: Session identifier
    /// - Returns: Publisher with session details
    public func getSession(sessionId: String) -> AnyPublisher<AIGameSession, APIError> {
        return apiClient.request(
            endpoint: APIClient.AIGamesEndpoint.getSession(sessionId: sessionId).path,
            method: .get
        )
    }
    
    /// Submit a challenge answer
    /// - Parameter request: Challenge submission with answer
    /// - Returns: Publisher with validation result
    public func submitChallenge(request: SubmitChallengeRequest) -> AnyPublisher<SubmitChallengeResponse, APIError> {
        return apiClient.request(
            endpoint: APIClient.AIGamesEndpoint.submitChallenge.path,
            method: .post,
            body: request
        )
    }
    
    /// Track a game event
    /// - Parameter request: Event tracking request
    /// - Returns: Publisher that completes when event is tracked
    public func trackEvent(request: TrackEventRequest) -> AnyPublisher<Void, APIError> {
        return apiClient.requestWithoutResponse(
            endpoint: APIClient.AIGamesEndpoint.trackEvent.path,
            method: .post,
            body: request
        )
    }
    
    /// End a game session
    /// - Parameter sessionId: Session identifier
    /// - Returns: Publisher with the completed session
    public func endSession(sessionId: String) -> AnyPublisher<AIGameSession, APIError> {
        return apiClient.request(
            endpoint: APIClient.AIGamesEndpoint.endSession(sessionId: sessionId).path,
            method: .post
        )
    }
    
    /// Get session history for a child
    /// - Parameter childId: Child identifier
    /// - Returns: Publisher with array of sessions
    public func getSessionHistory(childId: String) -> AnyPublisher<[AIGameSession], APIError> {
        return apiClient.request(
            endpoint: APIClient.AIGamesEndpoint.getSessionHistory(childId: childId).path,
            method: .get
        )
    }
    
    // MARK: - Progress and Analytics
    
    /// Get progress for a child
    /// - Parameter childId: Child identifier
    /// - Returns: Publisher with progress data
    public func getProgress(childId: String) -> AnyPublisher<AIGameProgress, APIError> {
        return apiClient.request(
            endpoint: APIClient.AIGamesEndpoint.getProgress(childId: childId).path,
            method: .get
        )
    }
    
    /// Get personality trait assessments for a child
    /// - Parameter childId: Child identifier
    /// - Returns: Publisher with trait assessments
    public func getTraitAssessments(childId: String) -> AnyPublisher<[TraitAssessment], APIError> {
        return apiClient.request(
            endpoint: APIClient.AIGamesEndpoint.getTraitAssessments(childId: childId).path,
            method: .get
        )
    }
}
