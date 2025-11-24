//
//  AIGameModels.swift
//  CleverooDAM
//
//  AI Games data models matching NestJS backend implementation
//

import Foundation

// MARK: - Game Models

/// Represents an AI-generated game
public struct AIGame: Codable, Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let gameType: GameType
    public let difficulty: Difficulty
    public let ageRange: AgeRange
    public let estimatedDuration: Int // minutes
    public let personalityTraits: [PersonalityTrait]
    public let instructions: String
    public let content: GameContent
    public let createdAt: Date
    public var isActive: Bool
    
    public enum GameType: String, Codable {
        case puzzle
        case memory
        case logic
        case creativity
        case math
        case language
    }
    
    public enum Difficulty: String, Codable {
        case easy
        case medium
        case hard
    }
    
    public struct AgeRange: Codable {
        public let min: Int
        public let max: Int
        
        public init(min: Int, max: Int) {
            self.min = min
            self.max = max
        }
    }
    
    public init(id: String = UUID().uuidString, title: String, description: String, gameType: GameType, difficulty: Difficulty, ageRange: AgeRange, estimatedDuration: Int, personalityTraits: [PersonalityTrait], instructions: String, content: GameContent, createdAt: Date = Date(), isActive: Bool = true) {
        self.id = id
        self.title = title
        self.description = description
        self.gameType = gameType
        self.difficulty = difficulty
        self.ageRange = ageRange
        self.estimatedDuration = estimatedDuration
        self.personalityTraits = personalityTraits
        self.instructions = instructions
        self.content = content
        self.createdAt = createdAt
        self.isActive = isActive
    }
}

/// Game content structure
public struct GameContent: Codable {
    public let levels: [GameLevel]
    public let assets: [String: String] // asset name to URL mapping
    public let metadata: [String: String]
    
    public init(levels: [GameLevel], assets: [String: String] = [:], metadata: [String: String] = [:]) {
        self.levels = levels
        self.assets = assets
        self.metadata = metadata
    }
}

/// Individual game level
public struct GameLevel: Codable, Identifiable {
    public let id: String
    public let levelNumber: Int
    public let title: String
    public let challenges: [Challenge]
    public let timeLimit: Int? // seconds, nil for untimed
    
    public init(id: String = UUID().uuidString, levelNumber: Int, title: String, challenges: [Challenge], timeLimit: Int? = nil) {
        self.id = id
        self.levelNumber = levelNumber
        self.title = title
        self.challenges = challenges
        self.timeLimit = timeLimit
    }
}

/// Game challenge/task
public struct Challenge: Codable, Identifiable {
    public let id: String
    public let prompt: String
    public let type: ChallengeType
    public let correctAnswer: String
    public let options: [String]? // for multiple choice
    public let hints: [String]
    
    public enum ChallengeType: String, Codable {
        case multipleChoice
        case freeText
        case dragAndDrop
        case matching
    }
    
    public init(id: String = UUID().uuidString, prompt: String, type: ChallengeType, correctAnswer: String, options: [String]? = nil, hints: [String] = []) {
        self.id = id
        self.prompt = prompt
        self.type = type
        self.correctAnswer = correctAnswer
        self.options = options
        self.hints = hints
    }
}

// MARK: - Personality Trait Models

/// Personality traits assessed during gameplay
public struct PersonalityTrait: Codable, Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let category: TraitCategory
    
    public enum TraitCategory: String, Codable {
        case cognitive
        case social
        case emotional
        case creative
        case physical
    }
    
    public init(id: String = UUID().uuidString, name: String, description: String, category: TraitCategory) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
    }
}

/// Assessment of a trait based on gameplay
public struct TraitAssessment: Codable {
    public let traitId: String
    public let traitName: String
    public let score: Double // 0-100
    public let level: AssessmentLevel
    public let observations: [String]
    
    public enum AssessmentLevel: String, Codable {
        case developing
        case emerging
        case proficient
        case advanced
    }
    
    public init(traitId: String, traitName: String, score: Double, level: AssessmentLevel, observations: [String]) {
        self.traitId = traitId
        self.traitName = traitName
        self.score = score
        self.level = level
        self.observations = observations
    }
}

// MARK: - Game Session Models

/// AI Game play session
public struct AIGameSession: Codable, Identifiable {
    public let id: String
    public let gameId: String
    public let childId: String
    public let startTime: Date
    public var endTime: Date?
    public var currentLevel: Int
    public var completedChallenges: [CompletedChallenge]
    public var score: Int
    public var events: [GameEvent]
    public var isCompleted: Bool
    
    public init(id: String = UUID().uuidString, gameId: String, childId: String, startTime: Date = Date(), endTime: Date? = nil, currentLevel: Int = 1, completedChallenges: [CompletedChallenge] = [], score: Int = 0, events: [GameEvent] = [], isCompleted: Bool = false) {
        self.id = id
        self.gameId = gameId
        self.childId = childId
        self.startTime = startTime
        self.endTime = endTime
        self.currentLevel = currentLevel
        self.completedChallenges = completedChallenges
        self.score = score
        self.events = events
        self.isCompleted = isCompleted
    }
}

/// Completed challenge within a session
public struct CompletedChallenge: Codable, Identifiable {
    public let id: String
    public let challengeId: String
    public let levelNumber: Int
    public let userAnswer: String
    public let isCorrect: Bool
    public let timeSpent: TimeInterval
    public let hintsUsed: Int
    public let completedAt: Date
    
    public init(id: String = UUID().uuidString, challengeId: String, levelNumber: Int, userAnswer: String, isCorrect: Bool, timeSpent: TimeInterval, hintsUsed: Int, completedAt: Date = Date()) {
        self.id = id
        self.challengeId = challengeId
        self.levelNumber = levelNumber
        self.userAnswer = userAnswer
        self.isCorrect = isCorrect
        self.timeSpent = timeSpent
        self.hintsUsed = hintsUsed
        self.completedAt = completedAt
    }
}

/// Game event for tracking
public struct GameEvent: Codable, Identifiable {
    public let id: String
    public let eventType: EventType
    public let timestamp: Date
    public let data: [String: String]
    
    public enum EventType: String, Codable {
        case gameStarted
        case levelStarted
        case levelCompleted
        case challengeAttempted
        case challengeCompleted
        case hintRequested
        case pauseRequested
        case gameCompleted
        case gameAbandoned
    }
    
    public init(id: String = UUID().uuidString, eventType: EventType, timestamp: Date = Date(), data: [String: String] = [:]) {
        self.id = id
        self.eventType = eventType
        self.timestamp = timestamp
        self.data = data
    }
}

// MARK: - Progress and Analytics Models

/// Child's progress in AI Games
public struct AIGameProgress: Codable {
    public let childId: String
    public let totalGamesPlayed: Int
    public let totalGamesCompleted: Int
    public let totalTimeSpent: TimeInterval
    public let averageScore: Double
    public let traitAssessments: [TraitAssessment]
    public let favoriteGameTypes: [AIGame.GameType]
    public let lastPlayedAt: Date?
    
    public var completionRate: Double {
        guard totalGamesPlayed > 0 else { return 0 }
        return (Double(totalGamesCompleted) / Double(totalGamesPlayed)) * 100
    }
    
    public init(childId: String, totalGamesPlayed: Int, totalGamesCompleted: Int, totalTimeSpent: TimeInterval, averageScore: Double, traitAssessments: [TraitAssessment], favoriteGameTypes: [AIGame.GameType], lastPlayedAt: Date?) {
        self.childId = childId
        self.totalGamesPlayed = totalGamesPlayed
        self.totalGamesCompleted = totalGamesCompleted
        self.totalTimeSpent = totalTimeSpent
        self.averageScore = averageScore
        self.traitAssessments = traitAssessments
        self.favoriteGameTypes = favoriteGameTypes
        self.lastPlayedAt = lastPlayedAt
    }
}

// MARK: - API Request/Response Models

/// Request to generate a new AI game
public struct GenerateGameRequest: Codable {
    public let childId: String
    public let gameType: AIGame.GameType
    public let difficulty: AIGame.Difficulty
    public let ageRange: AIGame.AgeRange
    public let focusTraits: [String]? // trait IDs to focus on
    
    public init(childId: String, gameType: AIGame.GameType, difficulty: AIGame.Difficulty, ageRange: AIGame.AgeRange, focusTraits: [String]? = nil) {
        self.childId = childId
        self.gameType = gameType
        self.difficulty = difficulty
        self.ageRange = ageRange
        self.focusTraits = focusTraits
    }
}

/// Request to start a game session
public struct StartGameSessionRequest: Codable {
    public let gameId: String
    public let childId: String
    
    public init(gameId: String, childId: String) {
        self.gameId = gameId
        self.childId = childId
    }
}

/// Request to submit a challenge answer
public struct SubmitChallengeRequest: Codable {
    public let sessionId: String
    public let challengeId: String
    public let answer: String
    public let timeSpent: TimeInterval
    public let hintsUsed: Int
    
    public init(sessionId: String, challengeId: String, answer: String, timeSpent: TimeInterval, hintsUsed: Int = 0) {
        self.sessionId = sessionId
        self.challengeId = challengeId
        self.answer = answer
        self.timeSpent = timeSpent
        self.hintsUsed = hintsUsed
    }
}

/// Response for submitted challenge
public struct SubmitChallengeResponse: Codable {
    public let isCorrect: Bool
    public let correctAnswer: String
    public let pointsEarned: Int
    public let totalScore: Int
    public let feedback: String
    public let nextChallenge: Challenge?
    
    public init(isCorrect: Bool, correctAnswer: String, pointsEarned: Int, totalScore: Int, feedback: String, nextChallenge: Challenge? = nil) {
        self.isCorrect = isCorrect
        self.correctAnswer = correctAnswer
        self.pointsEarned = pointsEarned
        self.totalScore = totalScore
        self.feedback = feedback
        self.nextChallenge = nextChallenge
    }
}

/// Request to track a game event
public struct TrackEventRequest: Codable {
    public let sessionId: String
    public let eventType: GameEvent.EventType
    public let data: [String: String]
    
    public init(sessionId: String, eventType: GameEvent.EventType, data: [String: String] = [:]) {
        self.sessionId = sessionId
        self.eventType = eventType
        self.data = data
    }
}
