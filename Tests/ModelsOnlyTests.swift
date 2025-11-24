//
//  ModelsOnlyTests.swift
//  CleverooDAM
//
//  Basic tests for data models that don't require Combine or SwiftUI
//

import Foundation

// Test that models can be instantiated and used correctly
func testMentalMathModels() {
    // Test MathQuestion
    let question = MathQuestion(
        question: "2 + 2",
        correctAnswer: 4,
        difficulty: .easy,
        timeLimit: 30
    )
    assert(question.question == "2 + 2")
    assert(question.correctAnswer == 4)
    
    // Test MentalMathSession
    let session = MentalMathSession(childId: "child123")
    assert(session.childId == "child123")
    assert(session.totalScore == 0)
    
    // Test MentalMathProgress
    let progress = MentalMathProgress(
        childId: "child123",
        totalSessions: 10,
        totalQuestionsAnswered: 100,
        correctAnswers: 80,
        averageScore: 80.0,
        averageTimePerQuestion: 10.5,
        lastPlayedAt: Date(),
        difficultyDistribution: ["easy": 40, "medium": 40, "hard": 20]
    )
    assert(progress.accuracyPercentage == 80.0)
    
    print("✅ Mental Math models tests passed")
}

func testAIGameModels() {
    // Test AIGame
    let game = AIGame(
        title: "Test Game",
        description: "A test game",
        gameType: .puzzle,
        difficulty: .medium,
        ageRange: AIGame.AgeRange(min: 6, max: 10),
        estimatedDuration: 15,
        personalityTraits: [],
        instructions: "Test instructions",
        content: GameContent(levels: [])
    )
    assert(game.title == "Test Game")
    assert(game.gameType == .puzzle)
    
    // Test Challenge
    let challenge = Challenge(
        prompt: "What is 2 + 2?",
        type: .multipleChoice,
        correctAnswer: "4",
        options: ["2", "3", "4", "5"]
    )
    assert(challenge.prompt == "What is 2 + 2?")
    assert(challenge.correctAnswer == "4")
    
    // Test AIGameSession
    let session = AIGameSession(
        gameId: "game123",
        childId: "child123"
    )
    assert(session.gameId == "game123")
    assert(session.currentLevel == 1)
    
    // Test AIGameProgress
    let progress = AIGameProgress(
        childId: "child123",
        totalGamesPlayed: 10,
        totalGamesCompleted: 7,
        totalTimeSpent: 3600,
        averageScore: 85.0,
        traitAssessments: [],
        favoriteGameTypes: [.puzzle, .memory],
        lastPlayedAt: Date()
    )
    assert(progress.completionRate == 70.0)
    
    print("✅ AI Game models tests passed")
}

// Run tests
testMentalMathModels()
testAIGameModels()
print("✅ All basic model tests passed!")
