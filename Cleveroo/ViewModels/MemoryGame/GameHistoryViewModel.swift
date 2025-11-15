//
//  GameHistoryViewModel.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 15/11/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class GameHistoryViewModel: ObservableObject {
    @Published var sessions: [MemoryGameSession] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Computed Statistics
    var totalScore: Int {
        sessions.reduce(0) { $0 + $1.score }
    }
    
    var bestScore: Int {
        sessions.map { $0.score }.max() ?? 0
    }
    
    var winRate: Int {
        guard !sessions.isEmpty else { return 0 }
        let completedGames = sessions.filter { $0.status == .COMPLETED }.count
        return Int((Double(completedGames) / Double(sessions.count)) * 100)
    }
    
    var averageTime: Int {
        guard !sessions.isEmpty else { return 0 }
        let totalTime = sessions.reduce(0) { $0 + $1.timeSpent }
        return totalTime / sessions.count
    }
    
    var totalGamesPlayed: Int {
        sessions.count
    }
    
    var perfectGames: Int {
        sessions.filter { $0.perfectPairs == $0.pairsFound }.count
    }
    
    // MARK: - Load History
    func loadHistory(userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("📊 Loading game history for user: \(userId)")
            sessions = try await MemoryGameService.shared.getGameHistory(userId: userId)
            
            // Trier par date décroissante (plus récent en premier)
            sessions.sort { $0.startTime > $1.startTime }
            
            print("✅ Loaded \(sessions.count) game sessions")
            print("📈 Total Score: \(totalScore)")
            print("🏆 Best Score: \(bestScore)")
            print("💯 Win Rate: \(winRate)%")
        } catch {
            errorMessage = "Failed to load history: \(error.localizedDescription)"
            print("❌ Error loading history: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Filter Sessions
    func filterByStatus(_ status: MemoryGameSession.SessionStatus) -> [MemoryGameSession] {
        sessions.filter { $0.status == status }
    }
    
    func filterByDateRange(from startDate: Date, to endDate: Date) -> [MemoryGameSession] {
        sessions.filter { session in
            session.startTime >= startDate && session.startTime <= endDate
        }
    }
    
    func topSessions(limit: Int = 5) -> [MemoryGameSession] {
        Array(sessions.sorted { $0.score > $1.score }.prefix(limit))
    }
}
