//
//  AIReportViewModel.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 7/11/2025.
//

import Foundation
import Combine
import SwiftUI

class AIReportViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var overallScore: Double = 0
    @Published var emotionalScore: Double = 0
    @Published var memoryScore: Double = 0
    @Published var focusScore: Double = 0
    @Published var creativityScore: Double = 0
    
    @Published var cleverooAdvice: String = ""
    @Published var dailyTips: [String] = []
    @Published var isLoading = false
    
    // 📊 For chart compatibility
    @Published var skillProgress: [SkillData] = []
    
    struct SkillData: Identifiable {
        let id = UUID()
        let name: String
        let value: Double
    }
    
    // MARK: - Internal data simulation
    private let advices = [
        "You’re doing amazing! 🌟 Try drawing or storytelling to boost creativity.",
        "Remember to take small breaks to stay focused 🕹️",
        "Keep a gratitude journal to strengthen emotional intelligence 💖",
        "Challenge your memory with a fun game or song 🎵",
        "Meditation can help you stay calm and focused 🧘‍♂️",
        "Keep exploring new puzzles — your brain loves challenges 🧩"
    ]
    
    private let tips = [
        "✨ Play a memory match game to improve recall.",
        "🎨 Color a picture to relax your mind.",
        "💡 Spend 5 minutes breathing calmly before studying.",
        "📚 Read a short story and tell it in your own words.",
        "🧩 Do a puzzle with a parent to boost teamwork!"
    ]
    
    // MARK: - Initialization
    init() {
        generateMockData()
    }
    
    // MARK: - Load Mock Data (Temporary)
    func generateMockData() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.overallScore = Double.random(in: 60...100)
            self.emotionalScore = Double.random(in: 60...100)
            self.memoryScore = Double.random(in: 60...100)
            self.focusScore = Double.random(in: 60...100)
            self.creativityScore = Double.random(in: 60...100)
            
            self.skillProgress = [
                .init(name: "Emotions", value: self.emotionalScore),
                .init(name: "Memory", value: self.memoryScore),
                .init(name: "Focus", value: self.focusScore),
                .init(name: "Creativity", value: self.creativityScore)
            ]
            
            self.cleverooAdvice = self.advices.randomElement() ?? ""
            self.dailyTips = Array(self.tips.shuffled().prefix(3))
            
            self.isLoading = false
        }
    }
    
    // MARK: - Refresh Advice
    func generateNewAdvice() {
        cleverooAdvice = advices.randomElement() ?? cleverooAdvice
        dailyTips = Array(tips.shuffled().prefix(3))
    }
    
    // MARK: - Placeholder for future AI integration
    func fetchAIReportData(forUser userId: String) {
        // 🚧 To be implemented when backend is ready
        // e.g., APIService.shared.fetchAIReport(userId: userId)
    }
}

