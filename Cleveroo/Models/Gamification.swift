//
//  Gamification.swift
//  Cleveroo
//
//  Created by GitHub Copilot on 30/11/2025.
//

import Foundation

// MARK: - Badge Model
struct Badge: Codable, Identifiable, Hashable {
    let id: String
    let badgeId: String
    let name: String
    let icon: String
    let description: String
    let unlocked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case badgeId, name, icon, description, unlocked
    }
    
    // Pour les badges qui viennent de l'API sans le champ unlocked
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Essayer de décoder _id, sinon utiliser badgeId comme fallback
        if let idValue = try? container.decode(String.self, forKey: .id) {
            id = idValue
        } else {
            id = try container.decode(String.self, forKey: .badgeId)
        }
        
        badgeId = try container.decode(String.self, forKey: .badgeId)
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decode(String.self, forKey: .icon)
        description = try container.decode(String.self, forKey: .description)
        unlocked = (try? container.decode(Bool.self, forKey: .unlocked)) ?? false
    }
}

// MARK: - Child Info for Leaderboard
struct ChildInfo: Codable {
    let id: String
    let username: String
    let avatar: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username
        case avatar
    }
}

// MARK: - Gamification Leaderboard Entry
struct GamificationLeaderboardEntry: Codable, Identifiable {
    let rank: Int
    let childId: ChildInfo?
    let xp: Int
    let level: Int
    let currentStreak: Int
    let unlockedBadgesCount: Int
    
    var id: String {
        if let childId = childId {
            return childId.id + String(rank)
        }
        return "empty_" + String(rank)
    }
    
    var playerName: String {
        childId?.username ?? "Joueur #\(rank)"
    }
    
    var avatarURL: String? {
        childId?.avatar
    }
}

// MARK: - Badge with Status Response
struct GamificationStats: Codable {
    let totalGames: Int?
    let totalActivities: Int?
    let totalMentalMath: Int?
    let creativityScores: [Int]?
    let creativityAvg: Int?
    let fastestReactionTime: Int?
    let starsCollected: Int?
}

// MARK: - Gamification Profile
struct GamificationProfile: Codable {
    let childId: String?
    let xp: Int
    let level: Int
    let currentStreak: Int
    let unlockedBadges: [Badge]
    let stats: GamificationStats?
    
    var xpToNextLevel: Int {
        return (level * 100) - xp
    }
    
    var progressToNextLevel: Double {
        let currentLevelXP = (level - 1) * 100
        let nextLevelXP = level * 100
        let progressXP = xp - currentLevelXP
        let totalXPNeeded = nextLevelXP - currentLevelXP
        return Double(progressXP) / Double(totalXPNeeded)
    }
}



// MARK: - Badge with Status Response
struct BadgeWithStatus: Codable, Identifiable {
    let badgeId: String
    let name: String
    let icon: String
    let description: String
    let unlocked: Bool
    
    var id: String { badgeId }
}
