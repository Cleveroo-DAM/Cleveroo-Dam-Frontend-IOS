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
    @Published var areasNeedingImprovement: [String] = []
    @Published var strengths: [String] = []
    @Published var personalisedRecommendations: [String] = []
    
    // 📊 For chart compatibility
    @Published var skillProgress: [SkillData] = []
    
    struct SkillData: Identifiable {
        let id = UUID()
        let name: String
        let value: Double
    }
    
    // MARK: - Internal data simulation - Generic advices
    private let genericAdvices = [
        "You're doing amazing! 🌟 Try drawing or storytelling to boost creativity.",
        "Remember to take small breaks to stay focused 🕹️",
        "Keep a gratitude journal to strengthen emotional intelligence 💖",
        "Challenge your memory with a fun game or song 🎵",
        "Meditation can help you stay calm and focused 🧘‍♂️",
        "Keep exploring new puzzles — your brain loves challenges 🧩"
    ]
    
    // MARK: - Personalized tips based on performance
    private let creativityTips = [
        "🎨 Draw or paint something you love today!",
        "✍️ Write a short story about your favorite adventure.",
        "🎭 Try acting out different characters or emotions.",
        "🎵 Create a song or rhythm with household items."
    ]
    
    private let memoryTips = [
        "🧩 Play memory match games regularly.",
        "🎵 Learn a new song or poem by heart.",
        "📝 Write down things you want to remember.",
        "🏃‍♂️ Exercise helps improve memory and focus!"
    ]
    
    private let focusTips = [
        "🎯 Start with small tasks before bigger ones.",
        "⏱️ Use a timer to stay on track (15-20 mins).",
        "🌳 Take nature breaks away from screens.",
        "💧 Stay hydrated and eat healthy snacks!"
    ]
    
    private let emotionalTips = [
        "💖 Talk about your feelings with someone you trust.",
        "😊 Practice smiling and saying kind words.",
        "🧘‍♀️ Try deep breathing when you feel overwhelmed.",
        "🤗 Help others and spread kindness around you!"
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
            
            self.generatePersonalisedReport()
            self.isLoading = false
        }
    }
    
    // MARK: - Refresh Advice
    func generateNewAdvice() {
        cleverooAdvice = generatePersonalisedAdvice()
        dailyTips = generatePersonalisedTips()
    }
    
    // MARK: - Placeholder for future AI integration
    func fetchAIReportData(forUser userId: String) {
        // 🚧 To be implemented when backend is ready
        // e.g., APIService.shared.fetchAIReport(userId: userId)
    }
    
    // MARK: - Load Child Report Data from Activities
    func loadChildReport(childId: String, assignments: [ActivityAssignment] = []) {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.calculateScoresFromActivities(assignments: assignments)
            self.generatePersonalisedReport()
            self.isLoading = false
        }
    }
    
    // MARK: - Calculate Scores from Child Activities
    private func calculateScoresFromActivities(assignments: [ActivityAssignment]) {
        // Filtrer les activités complétées avec des scores
        let completedActivities = assignments.filter {
            $0.status == "completed" && $0.score != nil
        }
        
        if completedActivities.isEmpty {
            // Si aucune activité complétée, générer des scores par défaut
            self.overallScore = 65
            self.emotionalScore = 70
            self.memoryScore = 60
            self.focusScore = 65
            self.creativityScore = 75
        } else {
            // Calculer la moyenne globale
            let scores = completedActivities.compactMap { $0.score }
            self.overallScore = Double(scores.reduce(0, +)) / Double(scores.count)
            
            // Catégoriser les activités par domaine et calculer les scores
            self.categorizeAndCalculateScores(assignments: completedActivities)
        }
        
        // Mettre à jour le graphique des compétences
        self.skillProgress = [
            .init(name: "Emotions", value: self.emotionalScore),
            .init(name: "Memory", value: self.memoryScore),
            .init(name: "Focus", value: self.focusScore),
            .init(name: "Creativity", value: self.creativityScore)
        ]
    }
    
    // MARK: - Categorize Activities by Domain
    private func categorizeAndCalculateScores(assignments: [ActivityAssignment]) {
        // Grouper par domaine
        var emotionalActivities: [Int] = []
        var memoryActivities: [Int] = []
        var focusActivities: [Int] = []
        var creativityActivities: [Int] = []
        
        for assignment in assignments {
            if let score = assignment.score {
                let domain = assignment.activityId.domain.lowercased()
                
                switch domain {
                case "cognitive", "logic", "math":
                    focusActivities.append(score)
                case "memory", "puzzle":
                    memoryActivities.append(score)
                case "emotional", "social":
                    emotionalActivities.append(score)
                case "creativity", "art":
                    creativityActivities.append(score)
                default:
                    // Répartir aléatoirement si domaine inconnu
                    let random = Int.random(in: 0...3)
                    switch random {
                    case 0: emotionalActivities.append(score)
                    case 1: memoryActivities.append(score)
                    case 2: focusActivities.append(score)
                    default: creativityActivities.append(score)
                    }
                }
            }
        }
        
        // Calculer les moyennes par catégorie
        self.emotionalScore = emotionalActivities.isEmpty ? 65 : Double(emotionalActivities.reduce(0, +)) / Double(emotionalActivities.count)
        self.memoryScore = memoryActivities.isEmpty ? 70 : Double(memoryActivities.reduce(0, +)) / Double(memoryActivities.count)
        self.focusScore = focusActivities.isEmpty ? 65 : Double(focusActivities.reduce(0, +)) / Double(focusActivities.count)
        self.creativityScore = creativityActivities.isEmpty ? 75 : Double(creativityActivities.reduce(0, +)) / Double(creativityActivities.count)
    }
    
    // MARK: - Generate Personalised Report Based on Scores
    private func generatePersonalisedReport() {
        identifyStrengthsAndWeaknesses()
        cleverooAdvice = generatePersonalisedAdvice()
        dailyTips = generatePersonalisedTips()
        personalisedRecommendations = generateRecommendations()
    }
    
    // MARK: - Identify Strengths and Areas for Improvement
    private func identifyStrengthsAndWeaknesses() {
        var strengths: [String] = []
        var improvements: [String] = []
        
        let scores = [
            ("Emotional Intelligence 💖", emotionalScore),
            ("Memory 🧩", memoryScore),
            ("Focus 🎯", focusScore),
            ("Creativity 🎨", creativityScore)
        ]
        
        let sortedScores = scores.sorted { $0.1 > $1.1 }
        
        // Top 2 sont les forces
        if sortedScores.count > 0 && sortedScores[0].1 >= 70 {
            strengths.append(sortedScores[0].0)
        }
        if sortedScores.count > 1 && sortedScores[1].1 >= 70 {
            strengths.append(sortedScores[1].0)
        }
        
        // Bottom scores sont à améliorer
        if sortedScores.count > 2 && sortedScores[sortedScores.count - 1].1 < 75 {
            improvements.append(sortedScores[sortedScores.count - 1].0)
        }
        if sortedScores.count > 3 && sortedScores[sortedScores.count - 2].1 < 75 {
            improvements.append(sortedScores[sortedScores.count - 2].0)
        }
        
        self.strengths = strengths.isEmpty ? ["Great effort! 🌟"] : strengths
        self.areasNeedingImprovement = improvements.isEmpty ? [] : improvements
    }
    
    // MARK: - Generate Personalised Advice Based on Scores
    private func generatePersonalisedAdvice() -> String {
        let overallPerformance: String
        
        if overallScore >= 85 {
            overallPerformance = "🌟 Excellent work! You're shining bright! Keep up this amazing progress and challenge yourself with more complex activities."
        } else if overallScore >= 75 {
            overallPerformance = "👏 Great job! You're doing really well. Focus on improving the areas where you scored a bit lower to become even better!"
        } else if overallScore >= 60 {
            overallPerformance = "💪 Good effort! You're on the right track. Keep practicing, especially on memory and focus exercises to boost your score!"
        } else {
            overallPerformance = "🚀 You're just starting your learning journey. Don't give up! Every practice makes you stronger. Try one activity at a time!"
        }
        
        return overallPerformance
    }
    
    // MARK: - Generate Personalised Tips Based on Weak Areas
    private func generatePersonalisedTips() -> [String] {
        var selectedTips: [String] = []
        
        // Sélectionner les tips selon les scores faibles
        if emotionalScore < 75 {
            selectedTips.append(contentsOf: emotionalTips.shuffled().prefix(1))
        }
        
        if memoryScore < 75 {
            selectedTips.append(contentsOf: memoryTips.shuffled().prefix(1))
        }
        
        if focusScore < 75 {
            selectedTips.append(contentsOf: focusTips.shuffled().prefix(1))
        }
        
        if creativityScore < 75 {
            selectedTips.append(contentsOf: creativityTips.shuffled().prefix(1))
        }
        
        // Si tous les scores sont bons, ajouter des tips génériques
        if selectedTips.isEmpty {
            selectedTips.append(contentsOf: tips.shuffled().prefix(3))
        } else if selectedTips.count < 3 {
            selectedTips.append(contentsOf: tips.shuffled().prefix(3 - selectedTips.count))
        }
        
        return Array(selectedTips.prefix(3))
    }
    
    // MARK: - Generate Personalised Recommendations
    private func generateRecommendations() -> [String] {
        var recommendations: [String] = []
        
        // Recommandations basées sur chaque domaine
        if emotionalScore < 70 {
            recommendations.append("🎯 Focus on emotional activities: Try expressing feelings through art or journaling to strengthen emotional intelligence.")
        } else if emotionalScore >= 85 {
            recommendations.append("💖 Your emotional skills are excellent! Help others by sharing your empathy and kindness.")
        }
        
        if memoryScore < 70 {
            recommendations.append("🧩 Boost memory skills: Play memory games daily and practice recalling information through repetition.")
        } else if memoryScore >= 85 {
            recommendations.append("🧠 Your memory is strong! Try learning new skills like languages or complex patterns.")
        }
        
        if focusScore < 70 {
            recommendations.append("🎯 Improve focus: Use the Pomodoro technique (work 15 mins, break 5 mins) and minimize distractions.")
        } else if focusScore >= 85 {
            recommendations.append("🚀 Your focus is excellent! Tackle challenging projects that require sustained attention.")
        }
        
        if creativityScore < 70 {
            recommendations.append("🎨 Boost creativity: Try new art forms, write stories, or collaborate on creative projects.")
        } else if creativityScore >= 85 {
            recommendations.append("✨ Your creativity is wonderful! Share your ideas and create something unique!")
        }
        
        return recommendations
    }
}
