//
//  AIGame.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 24/11/2025.
//

import Foundation

// MARK: - Generated Game Models
struct GeneratedGame: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let domain: String
    let recommendedAgeMin: Int
    let recommendedAgeMax: Int?
    let durationSeconds: Int
    let spec: GameSpec
    let meta: GameMeta?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, description, domain, recommendedAgeMin, recommendedAgeMax, durationSeconds, spec, meta
    }
}

struct GameSpec: Codable {
    let steps: [GameStep]
    let metadata: GameMetadata?
}

struct GameStep: Codable, Identifiable {
    let id: String
    let type: StepType
    let prompt: String
    let options: [String]?
    let timeLimitSeconds: Int?
    let scoring: GameScoring?
    let metadata: StepMetadata?
}

enum StepType: String, Codable, CaseIterable {
    case question = "question"
    case task = "task"
    case choice = "choice"
    case timedReaction = "timed_reaction"
    case miniGame = "mini_game"
}

struct GameScoring: Codable {
    let type: String
    let traitWeights: [String: Double]?
    let direction: String?
}

struct StepMetadata: Codable {
    let uiHint: String?
}

struct GameMetadata: Codable {
    let theme: String?
    let colorScheme: String?
}

struct GameMeta: Codable {
    let parentId: String?
    let aiGeneratedAt: String?
    let notes: String?
}

// MARK: - Game Session Models
struct GameSession: Codable, Identifiable {
    let id: String
    let childId: String
    let gameId: String
    let status: SessionStatus
    let events: [GameEvent]
    let metrics: GameMetrics?
    let personalityResult: PersonalityResult?
    let progress: SessionProgress?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case childId, gameId, status, events, metrics, personalityResult, progress
    }
}

enum SessionStatus: String, Codable {
    case inProgress = "in_progress"
    case completed = "completed"
    case abandoned = "abandoned"
}

struct GameEvent: Codable {
    let type: String
    let stepId: String?
    let timestamp: Date
    let payload: EventPayload?
}

struct EventPayload: Codable {
    let answer: String?
    let correct: Bool?
    let rt: Double? // reaction time
    let choice: String?
    let accuracy: Double?
}

struct GameMetrics: Codable {
    let totalAnswers: Int?
    let correct: Int?
    let accuracy: Double?
    let meanRT: Double? // mean reaction time
}

struct PersonalityResult: Codable {
    let scores: PersonalityScores?
    let metrics: GameMetrics?
    let report: AIReport?
}

struct PersonalityScores: Codable {
    let attention: Int?
    let impulsivity: Int?
    let conscientiousness: Int?
    let openness: Int?
    let creativity: Int?
    let extraversion: Int?
    let agreeableness: Int?
    let neuroticism: Int?
}

struct AIReport: Codable {
    let text: String?
}

struct SessionProgress: Codable {
    let answeredSteps: Int
    let totalSteps: Int
    let percent: Int
    let lastUpdatedAt: String?
    
    var lastUpdatedDate: Date? {
        guard let dateString = lastUpdatedAt else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
}

// MARK: - Request/Response Models
struct GenerateGameRequest: Codable {
    let title: String?
    let domain: String
    let recommendedAgeMin: Int
    let recommendedAgeMax: Int?
    let constraints: String?
}

struct StartSessionResponse: Codable {
    let session: GameSession
    let game: GeneratedGame
}

struct PushEventsRequest: Codable {
    let events: [GameEvent]
}

struct PushEventsResponse: Codable {
    let ok: Bool
    let sessionId: String
    let metrics: GameMetrics?
    let progress: SessionProgress?
}

struct ChildProgressResponse: Codable {
    let childId: String
    let totalSessions: Int
    let completedSessions: Int
    let inProgress: Int
    let avgAccuracy: Double?
    let trend: [SessionTrend]
    let domainBreakdown: [String: DomainStats]
    let latestReport: PersonalityResult?
}

struct SessionTrend: Codable {
    let sessionId: String
    let createdAt: Date?
    let status: String
    let accuracy: Double?
    let meanRT: Double?
}

struct DomainStats: Codable {
    let count: Int
    let avgAccuracy: Double?
}

struct GamesForChildResponse: Codable {
    let games: [GeneratedGame]
    let totalGames: Int
    let childAge: Int?
}

// MARK: - Game Stats (pour tracker les parties jouées)
struct GameStats: Codable, Identifiable {
    let id: String
    let gameId: String
    let childId: String
    let timesPlayed: Int
    let bestScore: Double?
    let lastPlayedAt: String?
    let sessions: [GameSessionSummary]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case gameId, childId, timesPlayed, bestScore, lastPlayedAt, sessions
    }
}

struct GameSessionSummary: Codable, Identifiable {
    let id: String
    let status: String
    let score: Double?
    let createdAt: String?
    let accuracy: Double?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case status, score, createdAt, accuracy
    }
}
