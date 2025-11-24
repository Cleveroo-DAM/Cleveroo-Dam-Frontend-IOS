//
//  APIClient+Extensions.swift
//  CleverooDAM
//
//  API Client extensions for Mental Math and AI Games endpoints
//

import Foundation
import Combine

// MARK: - Mental Math Endpoints

extension APIClient {
    
    /// Mental Math API endpoints
    public enum MentalMathEndpoint {
        case startSession
        case getQuestion(sessionId: String)
        case submitAnswer
        case endSession
        case getProgress(childId: String)
        case getReport(childId: String, period: String)
        case getSession(sessionId: String)
        case getSessions(childId: String)
        
        var path: String {
            switch self {
            case .startSession:
                return "/api/mental-math/sessions/start"
            case .getQuestion(let sessionId):
                return "/api/mental-math/sessions/\(sessionId)/question"
            case .submitAnswer:
                return "/api/mental-math/sessions/submit-answer"
            case .endSession:
                return "/api/mental-math/sessions/end"
            case .getProgress(let childId):
                return "/api/mental-math/progress/\(childId)"
            case .getReport(let childId, let period):
                return "/api/mental-math/reports/\(childId)?period=\(period)"
            case .getSession(let sessionId):
                return "/api/mental-math/sessions/\(sessionId)"
            case .getSessions(let childId):
                return "/api/mental-math/sessions/child/\(childId)"
            }
        }
    }
}

// MARK: - AI Games Endpoints

extension APIClient {
    
    /// AI Games API endpoints
    public enum AIGamesEndpoint {
        case listGames(gameType: String?, difficulty: String?)
        case getGame(gameId: String)
        case generateGame
        case startSession
        case getSession(sessionId: String)
        case submitChallenge
        case trackEvent
        case endSession(sessionId: String)
        case getProgress(childId: String)
        case getTraitAssessments(childId: String)
        case getSessionHistory(childId: String)
        
        var path: String {
            switch self {
            case .listGames(let gameType, let difficulty):
                var path = "/api/ai-games"
                var params: [String] = []
                if let gameType = gameType {
                    params.append("gameType=\(gameType)")
                }
                if let difficulty = difficulty {
                    params.append("difficulty=\(difficulty)")
                }
                if !params.isEmpty {
                    path += "?" + params.joined(separator: "&")
                }
                return path
            case .getGame(let gameId):
                return "/api/ai-games/\(gameId)"
            case .generateGame:
                return "/api/ai-games/generate"
            case .startSession:
                return "/api/ai-games/sessions/start"
            case .getSession(let sessionId):
                return "/api/ai-games/sessions/\(sessionId)"
            case .submitChallenge:
                return "/api/ai-games/sessions/submit-challenge"
            case .trackEvent:
                return "/api/ai-games/sessions/track-event"
            case .endSession(let sessionId):
                return "/api/ai-games/sessions/\(sessionId)/end"
            case .getProgress(let childId):
                return "/api/ai-games/progress/\(childId)"
            case .getTraitAssessments(let childId):
                return "/api/ai-games/assessments/\(childId)"
            case .getSessionHistory(let childId):
                return "/api/ai-games/sessions/child/\(childId)"
            }
        }
    }
}

// MARK: - Convenience Methods

extension APIClient {
    
    /// Configure the API client with base URL and authentication
    /// - Parameters:
    ///   - baseURL: Base URL for API requests
    ///   - authToken: Authentication token (optional)
    public func configure(baseURL: String, authToken: String? = nil) {
        self.baseURL = baseURL
        self.authToken = authToken
    }
}
