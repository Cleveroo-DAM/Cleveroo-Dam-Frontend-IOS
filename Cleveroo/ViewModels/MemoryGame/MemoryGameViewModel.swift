//
//  MemoryGameViewModel.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 14/11/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class MemoryGameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var activities: [MemoryActivity] = []
    @Published var currentActivity: MemoryActivity?
    @Published var currentSession: MemoryGameSession?
    @Published var cards: [Card] = []
    @Published var flippedIndices: [Int] = []
    @Published var matchedPairs: Set<String> = []
    @Published var score: Int = 0
    @Published var moves: Int = 0
    @Published var timeElapsed: Int = 0
    @Published var isGameComplete: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var timer: Timer?
    private var gameStartTime: Date?
    private var failedAttempts: Int = 0
    private var perfectPairs: Int = 0
    private var lastMoveTime: Date?
    
    // MARK: - Load Activities
    func loadActivities() async {
        isLoading = true
        errorMessage = nil
        
        do {
            activities = try await MemoryGameService.shared.getActivities()
            print("✅ Loaded \(activities.count) activities")
        } catch {
            errorMessage = "Failed to load activities: \(error.localizedDescription)"
            print("❌ Error loading activities: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Start Game
    func startGame(activity: MemoryActivity, userId: String) async {
        isLoading = true
        errorMessage = nil
        currentActivity = activity
        
        do {
            currentSession = try await MemoryGameService.shared.startGame(
                activityId: activity.id,
                userId: userId
            )
            
            // Initialize cards
            setupCards(from: activity)
            
            // Start timer
            gameStartTime = Date()
            startTimer()
            
            print("✅ Game started - Session ID: \(currentSession?.id ?? "N/A")")
        } catch {
            errorMessage = "Failed to start game: \(error.localizedDescription)"
            print("❌ Error starting game: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Setup Cards
    private func setupCards(from activity: MemoryActivity) {
        var tempCards: [Card] = []
        
        // Create pairs
        for (index, cardId) in activity.cards.enumerated() {
            tempCards.append(Card(cardId: cardId, position: index * 2))
            tempCards.append(Card(cardId: cardId, position: index * 2 + 1))
        }
        
        // Shuffle
        cards = tempCards.shuffled().enumerated().map { index, card in
            var newCard = card
            newCard.position = index
            return newCard
        }
    }
    
    // MARK: - Flip Card
    func flipCard(at index: Int) {
        guard index < cards.count,
              !cards[index].isMatched,
              !cards[index].isFlipped,
              flippedIndices.count < 2 else {
            return
        }
        
        cards[index].isFlipped = true
        flippedIndices.append(index)
        
        if flippedIndices.count == 2 {
            moves += 1
            checkForMatch()
        }
    }
    
    // MARK: - Check for Match
    private func checkForMatch() {
        guard flippedIndices.count == 2 else { return }
        
        let firstIndex = flippedIndices[0]
        let secondIndex = flippedIndices[1]
        let firstCard = cards[firstIndex]
        let secondCard = cards[secondIndex]
        
        if firstCard.cardId == secondCard.cardId {
            // Match found!
            cards[firstIndex].isMatched = true
            cards[secondIndex].isMatched = true
            matchedPairs.insert(firstCard.cardId)
            score += 10
            
            // Check if it's a perfect pair (found on first try)
            if moves == matchedPairs.count {
                perfectPairs += 1
            }
            
            // Record move
            Task {
                await recordMove(card: firstCard, matched: true)
            }
            
            flippedIndices.removeAll()
            
            // Check if game is complete
            if matchedPairs.count == currentActivity?.pairs {
                completeGame()
            }
        } else {
            // No match
            failedAttempts += 1
            
            // Record move
            Task {
                await recordMove(card: firstCard, matched: false)
            }
            
            // Flip back after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.cards[firstIndex].isFlipped = false
                self.cards[secondIndex].isFlipped = false
                self.flippedIndices.removeAll()
            }
        }
    }
    
    // MARK: - Record Move
    private func recordMove(card: Card, matched: Bool) async {
        guard let sessionId = currentSession?.id else { return }
        
        let move = CardMove(
            cardId: card.cardId,
            position: card.position,
            timestamp: Date(),
            matched: matched
        )
        
        do {
            try await MemoryGameService.shared.recordMove(sessionId: sessionId, move: move)
            print("✅ Move recorded")
        } catch {
            print("❌ Failed to record move: \(error)")
        }
    }
    
    // MARK: - Complete Game
    private func completeGame() {
        stopTimer()
        isGameComplete = true
        
        Task {
            guard let sessionId = currentSession?.id else { return }
            
            let results = GameResults(
                score: score,
                timeSpent: timeElapsed,
                pairsFound: matchedPairs.count,
                totalMoves: moves,
                failedAttempts: failedAttempts,
                perfectPairs: perfectPairs
            )
            
            do {
                currentSession = try await MemoryGameService.shared.completeGame(
                    sessionId: sessionId,
                    results: results
                )
                print("✅ Game completed - Score: \(score)")
            } catch {
                print("❌ Failed to complete game: \(error)")
            }
        }
    }
    
    // MARK: - Timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timeElapsed += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Reset Game
    func resetGame() {
        stopTimer()
        cards.removeAll()
        flippedIndices.removeAll()
        matchedPairs.removeAll()
        score = 0
        moves = 0
        timeElapsed = 0
        failedAttempts = 0
        perfectPairs = 0
        isGameComplete = false
        currentSession = nil
        currentActivity = nil
    }
}
