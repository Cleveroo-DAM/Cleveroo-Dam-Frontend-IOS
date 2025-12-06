//
//  Report.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/12/2025.
//

import Foundation

// MARK: - Activity Statistics
struct ActivityStats: Codable {
    let totalSessions: Int
    let averageScore: Int
    let totalTimeMinutes: Int
    let completionRate: Int
    let recentScores: [Int]
    
    enum CodingKeys: String, CodingKey {
        case totalSessions, averageScore, totalTimeMinutes, completionRate, recentScores
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalSessions = try container.decodeIfPresent(Int.self, forKey: .totalSessions) ?? 0
        averageScore = try container.decodeIfPresent(Int.self, forKey: .averageScore) ?? 0
        totalTimeMinutes = try container.decodeIfPresent(Int.self, forKey: .totalTimeMinutes) ?? 0
        completionRate = try container.decodeIfPresent(Int.self, forKey: .completionRate) ?? 0
        recentScores = try container.decodeIfPresent([Int].self, forKey: .recentScores) ?? []
    }
    
    init(totalSessions: Int = 0, averageScore: Int = 0, totalTimeMinutes: Int = 0, completionRate: Int = 0, recentScores: [Int] = []) {
        self.totalSessions = totalSessions
        self.averageScore = averageScore
        self.totalTimeMinutes = totalTimeMinutes
        self.completionRate = completionRate
        self.recentScores = recentScores
    }
}

// MARK: - Personality Insight
struct PersonalityInsight: Codable, Identifiable {
    var id: String { trait }
    let trait: String
    let score: Int
    let trend: String // "increasing", "stable", "decreasing"
    
    var trendEmoji: String {
        switch trend {
        case "increasing": return "📈"
        case "decreasing": return "📉"
        default: return "➡️"
        }
    }
    
    var traitDisplayName: String {
        switch trait {
        case "creativity": return "Créativité"
        case "focus": return "Concentration"
        case "speed": return "Vitesse"
        case "accuracy": return "Précision"
        case "problemSolving": return "Résolution de problèmes"
        default: return trait.capitalized
        }
    }
}

// MARK: - AI Recommendation
struct AIRecommendation: Codable, Identifiable {
    var id: String { UUID().uuidString }
    let category: String // "strengths", "improvements", "activities"
    let title: String
    let description: String
    let priority: String // "high", "medium", "low"
    
    var priorityColor: String {
        switch priority {
        case "high": return "red"
        case "medium": return "orange"
        default: return "blue"
        }
    }
    
    var categoryIcon: String {
        switch category {
        case "strengths": return "star.fill"
        case "improvements": return "arrow.up.circle.fill"
        case "activities": return "gamecontroller.fill"
        default: return "lightbulb.fill"
        }
    }
}

// MARK: - Chart Data
struct ChartData: Codable {
    let xpProgression: [XPDataPoint]
    let scoresByActivity: [ActivityScore]
    let timeDistribution: [TimeDistribution]
    
    struct XPDataPoint: Codable, Identifiable {
        var id: String { date }
        let date: String
        let xp: Int
    }
    
    struct ActivityScore: Codable, Identifiable {
        var id: String { activity }
        let activity: String
        let avgScore: Int
    }
    
    struct TimeDistribution: Codable, Identifiable {
        var id: String { activity }
        let activity: String
        let minutes: Int
    }
}

// MARK: - Report Model
struct Report: Codable, Identifiable {
    let id: String
    let childId: ChildInfo
    let parentId: String
    let period: String // "daily", "weekly", "monthly"
    let startDate: Date
    let endDate: Date
    let title: String
    let summary: String
    
    // Statistics
    let aiGames: ActivityStats
    let memoryGames: ActivityStats
    let mentalMath: ActivityStats
    let activities: ActivityStats
    
    // Gamification
    let totalXP: Int
    let xpGained: Int
    let currentLevel: Int
    let currentStreak: Int
    let newBadges: [String]
    let totalScreenTimeMinutes: Int
    
    // AI Analysis
    let personalityInsights: [PersonalityInsight]
    let recommendations: [AIRecommendation]
    let strengths: [String]
    let areasForImprovement: [String]
    let overallPerformance: String // "excellent", "good", "needs_attention"
    
    // Charts
    let chartData: ChartData?
    let coverImage: String?
    
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case childId, parentId, period, startDate, endDate, title, summary
        case aiGames, memoryGames, mentalMath, activities
        case totalXP, xpGained, currentLevel, currentStreak, newBadges, totalScreenTimeMinutes
        case personalityInsights, recommendations, strengths, areasForImprovement, overallPerformance
        case chartData, coverImage
        case createdAt, updatedAt
    }
    
    struct ChildInfo: Codable {
        let id: String
        let username: String
        let avatar: String?
        let age: Int?
        let gender: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case username, avatar, age, gender
        }
    }
    
    // Helper computed properties
    var periodDisplayName: String {
        switch period {
        case "daily": return "Quotidien"
        case "weekly": return "Hebdomadaire"
        case "monthly": return "Mensuel"
        default: return period.capitalized
        }
    }
    
    var performanceColor: String {
        switch overallPerformance {
        case "excellent": return "green"
        case "good": return "blue"
        case "needs_attention": return "orange"
        default: return "gray"
        }
    }
    
    var performanceEmoji: String {
        switch overallPerformance {
        case "excellent": return "🌟"
        case "good": return "👍"
        case "needs_attention": return "💪"
        default: return "📊"
        }
    }
    
    var totalActivities: Int {
        aiGames.totalSessions + memoryGames.totalSessions + mentalMath.totalSessions + activities.totalSessions
    }
    
    var overallAverageScore: Int {
        let total = aiGames.averageScore + memoryGames.averageScore + mentalMath.averageScore + activities.averageScore
        let count = [aiGames, memoryGames, mentalMath, activities].filter { $0.totalSessions > 0 }.count
        return count > 0 ? total / count : 0
    }
    
    var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        formatter.locale = Locale(identifier: "fr_FR")
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

// MARK: - Report Request/Response DTOs
struct GenerateReportRequest: Codable {
    let childId: String
    let period: String
}

struct ReportsListResponse: Codable {
    let reports: [Report]
}
