//
//  CleverooDAMTests.swift
//  CleverooDAM
//
//  Basic tests for Mental Math and AI Games features
//

import XCTest
@testable import CleverooDAM

final class MentalMathModelsTests: XCTestCase {
    
    func testMathQuestionCreation() {
        let question = MathQuestion(
            question: "2 + 2",
            correctAnswer: 4,
            difficulty: .easy,
            timeLimit: 30
        )
        
        XCTAssertEqual(question.question, "2 + 2")
        XCTAssertEqual(question.correctAnswer, 4)
        XCTAssertEqual(question.difficulty, .easy)
        XCTAssertEqual(question.timeLimit, 30)
    }
    
    func testMentalMathSessionCreation() {
        let session = MentalMathSession(childId: "child123")
        
        XCTAssertEqual(session.childId, "child123")
        XCTAssertEqual(session.totalScore, 0)
        XCTAssertFalse(session.isCompleted)
        XCTAssertTrue(session.questions.isEmpty)
    }
    
    func testMentalMathProgressAccuracy() {
        let progress = MentalMathProgress(
            childId: "child123",
            totalSessions: 5,
            totalQuestionsAnswered: 50,
            correctAnswers: 40,
            averageScore: 80.0,
            averageTimePerQuestion: 10.5,
            lastPlayedAt: Date(),
            difficultyDistribution: ["easy": 20, "medium": 20, "hard": 10]
        )
        
        XCTAssertEqual(progress.accuracyPercentage, 80.0, accuracy: 0.01)
    }
    
    func testStartSessionRequest() {
        let request = StartSessionRequest(
            childId: "child123",
            difficulty: .medium,
            questionCount: 10
        )
        
        XCTAssertEqual(request.childId, "child123")
        XCTAssertEqual(request.difficulty, .medium)
        XCTAssertEqual(request.questionCount, 10)
    }
}

final class AIGameModelsTests: XCTestCase {
    
    func testAIGameCreation() {
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
        
        XCTAssertEqual(game.title, "Test Game")
        XCTAssertEqual(game.gameType, .puzzle)
        XCTAssertEqual(game.difficulty, .medium)
        XCTAssertTrue(game.isActive)
    }
    
    func testGameLevelCreation() {
        let challenge = Challenge(
            prompt: "Test question?",
            type: .multipleChoice,
            correctAnswer: "A",
            options: ["A", "B", "C", "D"]
        )
        
        let level = GameLevel(
            levelNumber: 1,
            title: "Level 1",
            challenges: [challenge],
            timeLimit: 60
        )
        
        XCTAssertEqual(level.levelNumber, 1)
        XCTAssertEqual(level.challenges.count, 1)
        XCTAssertEqual(level.timeLimit, 60)
    }
    
    func testAIGameSessionCreation() {
        let session = AIGameSession(
            gameId: "game123",
            childId: "child123"
        )
        
        XCTAssertEqual(session.gameId, "game123")
        XCTAssertEqual(session.childId, "child123")
        XCTAssertEqual(session.currentLevel, 1)
        XCTAssertEqual(session.score, 0)
        XCTAssertFalse(session.isCompleted)
    }
    
    func testAIGameProgressCompletionRate() {
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
        
        XCTAssertEqual(progress.completionRate, 70.0, accuracy: 0.01)
    }
    
    func testTraitAssessmentCreation() {
        let assessment = TraitAssessment(
            traitId: "trait123",
            traitName: "Problem Solving",
            score: 85.5,
            level: .proficient,
            observations: ["Good pattern recognition", "Solves problems methodically"]
        )
        
        XCTAssertEqual(assessment.traitName, "Problem Solving")
        XCTAssertEqual(assessment.score, 85.5, accuracy: 0.01)
        XCTAssertEqual(assessment.level, .proficient)
        XCTAssertEqual(assessment.observations.count, 2)
    }
}

final class APIClientTests: XCTestCase {
    
    func testAPIClientConfiguration() {
        let client = APIClient.shared
        
        client.configure(baseURL: "https://test.example.com", authToken: "test-token")
        
        XCTAssertEqual(client.baseURL, "https://test.example.com")
        XCTAssertEqual(client.getAuthToken(), "test-token")
    }
    
    func testMentalMathEndpointPaths() {
        XCTAssertEqual(
            APIClient.MentalMathEndpoint.startSession.path,
            "/api/mental-math/sessions/start"
        )
        XCTAssertEqual(
            APIClient.MentalMathEndpoint.getQuestion(sessionId: "session123").path,
            "/api/mental-math/sessions/session123/question"
        )
        XCTAssertEqual(
            APIClient.MentalMathEndpoint.getProgress(childId: "child123").path,
            "/api/mental-math/progress/child123"
        )
    }
    
    func testAIGamesEndpointPaths() {
        XCTAssertEqual(
            APIClient.AIGamesEndpoint.listGames(gameType: nil, difficulty: nil).path,
            "/api/ai-games"
        )
        XCTAssertEqual(
            APIClient.AIGamesEndpoint.getGame(gameId: "game123").path,
            "/api/ai-games/game123"
        )
        XCTAssertEqual(
            APIClient.AIGamesEndpoint.startSession.path,
            "/api/ai-games/sessions/start"
        )
    }
}

final class ViewModelTests: XCTestCase {
    
    @MainActor
    func testMentalMathGameViewModelInitialization() async {
        let viewModel = MentalMathGameViewModel(childId: "child123")
        
        XCTAssertNil(viewModel.currentSession)
        XCTAssertNil(viewModel.currentQuestion)
        XCTAssertEqual(viewModel.score, 0)
        XCTAssertEqual(viewModel.questionsAnswered, 0)
        XCTAssertEqual(viewModel.correctAnswers, 0)
        XCTAssertEqual(viewModel.gameState, .notStarted)
    }
    
    @MainActor
    func testMentalMathGameViewModelAccuracy() async {
        let viewModel = MentalMathGameViewModel(childId: "child123")
        
        viewModel.questionsAnswered = 10
        viewModel.correctAnswers = 8
        
        XCTAssertEqual(viewModel.accuracyPercentage, 80.0, accuracy: 0.01)
    }
    
    @MainActor
    func testAIGameViewModelInitialization() async {
        let viewModel = AIGameViewModel(childId: "child123")
        
        XCTAssertNil(viewModel.currentGame)
        XCTAssertNil(viewModel.currentSession)
        XCTAssertEqual(viewModel.score, 0)
        XCTAssertEqual(viewModel.gameState, .browsing)
        XCTAssertTrue(viewModel.availableGames.isEmpty)
    }
}
