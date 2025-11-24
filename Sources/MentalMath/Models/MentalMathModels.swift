//
//  MentalMathModels.swift
//  CleverooDAM
//
//  Mental Math game data models matching NestJS backend implementation
//

import Foundation

// MARK: - Question Models

/// Represents a mathematical question in the Mental Math game
public struct MathQuestion: Codable, Identifiable {
    public let id: String
    public let question: String
    public let correctAnswer: Int
    public let difficulty: Difficulty
    public let timeLimit: Int // seconds
    public let createdAt: Date
    
    public enum Difficulty: String, Codable {
        case easy
        case medium
        case hard
    }
    
    public init(id: String = UUID().uuidString, question: String, correctAnswer: Int, difficulty: Difficulty, timeLimit: Int, createdAt: Date = Date()) {
        self.id = id
        self.question = question
        self.correctAnswer = correctAnswer
        self.difficulty = difficulty
        self.timeLimit = timeLimit
        self.createdAt = createdAt
    }
}

// MARK: - Session Models

/// Represents a Mental Math game session
public struct MentalMathSession: Codable, Identifiable {
    public let id: String
    public let childId: String
    public let startTime: Date
    public var endTime: Date?
    public var questions: [SessionQuestion]
    public var totalScore: Int
    public var isCompleted: Bool
    
    public init(id: String = UUID().uuidString, childId: String, startTime: Date = Date(), endTime: Date? = nil, questions: [SessionQuestion] = [], totalScore: Int = 0, isCompleted: Bool = false) {
        self.id = id
        self.childId = childId
        self.startTime = startTime
        self.endTime = endTime
        self.questions = questions
        self.totalScore = totalScore
        self.isCompleted = isCompleted
    }
}

/// Question within a session with user response
public struct SessionQuestion: Codable, Identifiable {
    public let id: String
    public let questionId: String
    public let question: String
    public let correctAnswer: Int
    public var userAnswer: Int?
    public var isCorrect: Bool?
    public var timeSpent: TimeInterval?
    public let answeredAt: Date?
    
    public init(id: String = UUID().uuidString, questionId: String, question: String, correctAnswer: Int, userAnswer: Int? = nil, isCorrect: Bool? = nil, timeSpent: TimeInterval? = nil, answeredAt: Date? = nil) {
        self.id = id
        self.questionId = questionId
        self.question = question
        self.correctAnswer = correctAnswer
        self.userAnswer = userAnswer
        self.isCorrect = isCorrect
        self.timeSpent = timeSpent
        self.answeredAt = answeredAt
    }
}

// MARK: - Progress Models

/// Child's progress in Mental Math
public struct MentalMathProgress: Codable {
    public let childId: String
    public let totalSessions: Int
    public let totalQuestionsAnswered: Int
    public let correctAnswers: Int
    public let averageScore: Double
    public let averageTimePerQuestion: Double
    public let lastPlayedAt: Date?
    public let difficultyDistribution: [String: Int]
    
    public var accuracyPercentage: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return (Double(correctAnswers) / Double(totalQuestionsAnswered)) * 100
    }
    
    public init(childId: String, totalSessions: Int, totalQuestionsAnswered: Int, correctAnswers: Int, averageScore: Double, averageTimePerQuestion: Double, lastPlayedAt: Date?, difficultyDistribution: [String: Int]) {
        self.childId = childId
        self.totalSessions = totalSessions
        self.totalQuestionsAnswered = totalQuestionsAnswered
        self.correctAnswers = correctAnswers
        self.averageScore = averageScore
        self.averageTimePerQuestion = averageTimePerQuestion
        self.lastPlayedAt = lastPlayedAt
        self.difficultyDistribution = difficultyDistribution
    }
}

// MARK: - Report Models

/// Parent report for Mental Math performance
public struct MentalMathReport: Codable {
    public let childId: String
    public let childName: String
    public let reportPeriod: ReportPeriod
    public let generatedAt: Date
    public let progress: MentalMathProgress
    public let recentSessions: [SessionSummary]
    public let strengths: [String]
    public let areasForImprovement: [String]
    
    public enum ReportPeriod: String, Codable {
        case daily
        case weekly
        case monthly
    }
    
    public init(childId: String, childName: String, reportPeriod: ReportPeriod, generatedAt: Date = Date(), progress: MentalMathProgress, recentSessions: [SessionSummary], strengths: [String], areasForImprovement: [String]) {
        self.childId = childId
        self.childName = childName
        self.reportPeriod = reportPeriod
        self.generatedAt = generatedAt
        self.progress = progress
        self.recentSessions = recentSessions
        self.strengths = strengths
        self.areasForImprovement = areasForImprovement
    }
}

/// Summary of a game session for reports
public struct SessionSummary: Codable, Identifiable {
    public let id: String
    public let date: Date
    public let score: Int
    public let questionsAnswered: Int
    public let correctAnswers: Int
    public let averageTime: Double
    
    public init(id: String, date: Date, score: Int, questionsAnswered: Int, correctAnswers: Int, averageTime: Double) {
        self.id = id
        self.date = date
        self.score = score
        self.questionsAnswered = questionsAnswered
        self.correctAnswers = correctAnswers
        self.averageTime = averageTime
    }
}

// MARK: - API Request/Response Models

/// Request to start a new Mental Math session
public struct StartSessionRequest: Codable {
    public let childId: String
    public let difficulty: MathQuestion.Difficulty
    public let questionCount: Int
    
    public init(childId: String, difficulty: MathQuestion.Difficulty, questionCount: Int = 10) {
        self.childId = childId
        self.difficulty = difficulty
        self.questionCount = questionCount
    }
}

/// Request to submit an answer
public struct SubmitAnswerRequest: Codable {
    public let sessionId: String
    public let questionId: String
    public let answer: Int
    public let timeSpent: TimeInterval
    
    public init(sessionId: String, questionId: String, answer: Int, timeSpent: TimeInterval) {
        self.sessionId = sessionId
        self.questionId = questionId
        self.answer = answer
        self.timeSpent = timeSpent
    }
}

/// Response for submitted answer
public struct SubmitAnswerResponse: Codable {
    public let isCorrect: Bool
    public let correctAnswer: Int
    public let pointsEarned: Int
    public let totalScore: Int
    
    public init(isCorrect: Bool, correctAnswer: Int, pointsEarned: Int, totalScore: Int) {
        self.isCorrect = isCorrect
        self.correctAnswer = correctAnswer
        self.pointsEarned = pointsEarned
        self.totalScore = totalScore
    }
}

/// Request to end a session
public struct EndSessionRequest: Codable {
    public let sessionId: String
    
    public init(sessionId: String) {
        self.sessionId = sessionId
    }
}
