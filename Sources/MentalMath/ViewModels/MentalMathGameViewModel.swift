//
//  MentalMathGameViewModel.swift
//  CleverooDAM
//
//  ViewModel for Mental Math game with Combine framework
//

import Foundation
import Combine

/// ViewModel managing Mental Math game state and business logic
@MainActor
public class MentalMathGameViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var currentSession: MentalMathSession?
    @Published public var currentQuestion: MathQuestion?
    @Published public var userAnswer: String = ""
    @Published public var score: Int = 0
    @Published public var questionsAnswered: Int = 0
    @Published public var correctAnswers: Int = 0
    @Published public var isLoading: Bool = false
    @Published public var error: String?
    @Published public var gameState: GameState = .notStarted
    @Published public var timeRemaining: TimeInterval = 0
    @Published public var showFeedback: Bool = false
    @Published public var lastAnswerCorrect: Bool = false
    
    // MARK: - Game State
    
    public enum GameState {
        case notStarted
        case playing
        case answerSubmitted
        case completed
        case error
    }
    
    // MARK: - Properties
    
    private let service: MentalMathService
    private let childId: String
    private var cancellables = Set<AnyCancellable>()
    private var questionStartTime: Date?
    private var timer: AnyCancellable?
    
    // MARK: - Initialization
    
    public init(childId: String, service: MentalMathService = MentalMathService()) {
        self.childId = childId
        self.service = service
    }
    
    // MARK: - Public Methods
    
    /// Start a new Mental Math session
    /// - Parameters:
    ///   - difficulty: Game difficulty level
    ///   - questionCount: Number of questions in the session
    public func startSession(difficulty: MathQuestion.Difficulty, questionCount: Int = 10) {
        isLoading = true
        error = nil
        
        let request = StartSessionRequest(
            childId: childId,
            difficulty: difficulty,
            questionCount: questionCount
        )
        
        service.startSession(request: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                    self?.gameState = .error
                }
            }, receiveValue: { [weak self] session in
                self?.currentSession = session
                self?.score = session.totalScore
                self?.gameState = .playing
                self?.loadNextQuestion()
            })
            .store(in: &cancellables)
    }
    
    /// Load the next question in the session
    public func loadNextQuestion() {
        guard let sessionId = currentSession?.id else { return }
        
        isLoading = true
        error = nil
        userAnswer = ""
        showFeedback = false
        
        service.getQuestion(sessionId: sessionId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                    if error.errorDescription?.contains("No more questions") == true {
                        self?.completeSession()
                    }
                }
            }, receiveValue: { [weak self] question in
                self?.currentQuestion = question
                self?.questionStartTime = Date()
                self?.timeRemaining = TimeInterval(question.timeLimit)
                self?.startTimer()
            })
            .store(in: &cancellables)
    }
    
    /// Submit the user's answer
    public func submitAnswer() {
        guard let sessionId = currentSession?.id,
              let questionId = currentQuestion?.id,
              let answer = Int(userAnswer),
              let startTime = questionStartTime else {
            return
        }
        
        stopTimer()
        isLoading = true
        error = nil
        
        let timeSpent = Date().timeIntervalSince(startTime)
        
        let request = SubmitAnswerRequest(
            sessionId: sessionId,
            questionId: questionId,
            answer: answer,
            timeSpent: timeSpent
        )
        
        service.submitAnswer(request: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                    self?.gameState = .error
                }
            }, receiveValue: { [weak self] response in
                self?.handleAnswerResponse(response)
            })
            .store(in: &cancellables)
    }
    
    /// End the current session
    public func endSession() {
        guard let sessionId = currentSession?.id else { return }
        
        stopTimer()
        isLoading = true
        
        let request = EndSessionRequest(sessionId: sessionId)
        
        service.endSession(request: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            }, receiveValue: { [weak self] session in
                self?.currentSession = session
                self?.completeSession()
            })
            .store(in: &cancellables)
    }
    
    /// Reset the game to start a new session
    public func reset() {
        stopTimer()
        currentSession = nil
        currentQuestion = nil
        userAnswer = ""
        score = 0
        questionsAnswered = 0
        correctAnswers = 0
        error = nil
        gameState = .notStarted
        showFeedback = false
    }
    
    // MARK: - Private Methods
    
    private func handleAnswerResponse(_ response: SubmitAnswerResponse) {
        score = response.totalScore
        questionsAnswered += 1
        lastAnswerCorrect = response.isCorrect
        
        if response.isCorrect {
            correctAnswers += 1
        }
        
        showFeedback = true
        gameState = .answerSubmitted
        
        // Auto-advance to next question after showing feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.loadNextQuestion()
        }
    }
    
    private func completeSession() {
        stopTimer()
        gameState = .completed
    }
    
    private func startTimer() {
        stopTimer()
        
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.stopTimer()
                    self.handleTimeout()
                }
            }
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    private func handleTimeout() {
        // Auto-submit with empty answer on timeout
        if !userAnswer.isEmpty {
            submitAnswer()
        } else {
            userAnswer = "0" // Default wrong answer
            submitAnswer()
        }
    }
    
    // MARK: - Computed Properties
    
    public var accuracyPercentage: Double {
        guard questionsAnswered > 0 else { return 0 }
        return (Double(correctAnswers) / Double(questionsAnswered)) * 100
    }
    
    public var formattedTimeRemaining: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
