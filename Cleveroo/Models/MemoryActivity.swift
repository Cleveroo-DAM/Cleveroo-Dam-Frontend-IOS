//
//  MemoryActivity.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 14/11/2025.
//

import Foundation

struct MemoryActivity: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let difficulty: Difficulty
    let rows: Int
    let cols: Int
    let pairs: Int
    let theme: String
    let cards: [String]
    let timeLimit: Int?
    let isActive: Bool
    
    enum Difficulty: String, Codable, CaseIterable {
        case EASY = "EASY"
        case MEDIUM = "MEDIUM"
        case HARD = "HARD"
        
        var displayName: String {
            switch self {
            case .EASY: return "Facile"
            case .MEDIUM: return "Moyen"
            case .HARD: return "Difficile"
            }
        }
        
        var icon: String {
            switch self {
            case .EASY: return "⭐️"
            case .MEDIUM: return "⭐️⭐️"
            case .HARD: return "⭐️⭐️⭐️"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, description, difficulty, rows, cols, pairs, theme, cards, timeLimit, isActive
    }
}
