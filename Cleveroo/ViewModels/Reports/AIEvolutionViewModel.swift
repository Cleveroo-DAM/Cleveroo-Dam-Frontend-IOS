//
//  AIEvolutionViewModel.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 7/11/2025.
//

import Foundation
import SwiftUI
import Combine

struct DailyScore: Identifiable {
    let id = UUID()
    let day: String
    let score: Double
}

class AIEvolutionViewModel: ObservableObject {
    @Published var overallData: [DailyScore] = []
    @Published var categoryData: [String: [DailyScore]] = [:]
    @Published var averageOverallScore: Double = 0.0
    
    func generateMockData() {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        overallData = days.map { DailyScore(day: $0, score: Double.random(in: 60...100)) }
        averageOverallScore = overallData.map(\.score).reduce(0, +) / Double(overallData.count)
        
        categoryData = [
            "Emotional": days.map { DailyScore(day: $0, score: Double.random(in: 60...100)) },
            "Memory": days.map { DailyScore(day: $0, score: Double.random(in: 60...100)) },
            "Focus": days.map { DailyScore(day: $0, score: Double.random(in: 60...100)) },
            "Creativity": days.map { DailyScore(day: $0, score: Double.random(in: 60...100)) }
        ]
    }
    
    func color(for category: String) -> Color {
        switch category {
        case "Emotional": return .pink
        case "Memory": return .mint
        case "Focus": return .blue
        case "Creativity": return .purple
        default: return .gray
        }
    }
}
