//
//  MentalMathGameView.swift
//  CleverooDAM
//
//  SwiftUI view for Mental Math game
//

import SwiftUI

/// Main view for Mental Math game
public struct MentalMathGameView: View {
    
    @StateObject private var viewModel: MentalMathGameViewModel
    @State private var selectedDifficulty: MathQuestion.Difficulty = .medium
    
    public init(childId: String) {
        _viewModel = StateObject(wrappedValue: MentalMathGameViewModel(childId: childId))
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    switch viewModel.gameState {
                    case .notStarted:
                        startView
                    case .playing, .answerSubmitted:
                        gameplayView
                    case .completed:
                        resultsView
                    case .error:
                        errorView
                    }
                }
                .padding()
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
            .navigationTitle("Mental Math")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Start View
    
    private var startView: some View {
        VStack(spacing: 30) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 100))
                .foregroundColor(.blue)
            
            Text("Mental Math Challenge")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Test your math skills with timed questions!")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Select Difficulty")
                    .font(.headline)
                
                Picker("Difficulty", selection: $selectedDifficulty) {
                    Text("Easy").tag(MathQuestion.Difficulty.easy)
                    Text("Medium").tag(MathQuestion.Difficulty.medium)
                    Text("Hard").tag(MathQuestion.Difficulty.hard)
                }
                .pickerStyle(.segmented)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            
            Button(action: startGame) {
                Label("Start Game", systemImage: "play.fill")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
            }
        }
        .padding()
    }
    
    // MARK: - Gameplay View
    
    private var gameplayView: some View {
        VStack(spacing: 25) {
            // Header with score and timer
            HStack {
                VStack(alignment: .leading) {
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.score)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(viewModel.formattedTimeRemaining)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.timeRemaining < 5 ? .red : .primary)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            
            // Progress
            HStack {
                Text("Question \(viewModel.questionsAnswered + 1)")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.correctAnswers)/\(viewModel.questionsAnswered) correct")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Question
            if let question = viewModel.currentQuestion {
                VStack(spacing: 20) {
                    Text(question.question)
                        .font(.system(size: 48, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    
                    TextField("Your answer", text: $viewModel.userAnswer)
                        .font(.title)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .disabled(viewModel.gameState == .answerSubmitted)
                    
                    if viewModel.showFeedback {
                        feedbackBanner
                    }
                    
                    Button(action: submitAnswer) {
                        Text("Submit Answer")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.userAnswer.isEmpty ? Color.gray : Color.green)
                            .cornerRadius(15)
                    }
                    .disabled(viewModel.userAnswer.isEmpty || viewModel.gameState == .answerSubmitted)
                }
            }
            
            Spacer()
            
            Button("End Game", role: .destructive, action: endGame)
                .font(.footnote)
        }
    }
    
    // MARK: - Feedback Banner
    
    private var feedbackBanner: some View {
        HStack {
            Image(systemName: viewModel.lastAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title2)
            Text(viewModel.lastAnswerCorrect ? "Correct!" : "Incorrect")
                .font(.headline)
        }
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(viewModel.lastAnswerCorrect ? Color.green : Color.red)
        .cornerRadius(10)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    // MARK: - Results View
    
    private var resultsView: some View {
        VStack(spacing: 30) {
            Image(systemName: "star.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
            
            Text("Game Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                ResultRow(title: "Final Score", value: "\(viewModel.score)")
                ResultRow(title: "Questions Answered", value: "\(viewModel.questionsAnswered)")
                ResultRow(title: "Correct Answers", value: "\(viewModel.correctAnswers)")
                ResultRow(
                    title: "Accuracy",
                    value: String(format: "%.1f%%", viewModel.accuracyPercentage)
                )
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            
            Button(action: playAgain) {
                Text("Play Again")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
            }
        }
        .padding()
    }
    
    // MARK: - Error View
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Something went wrong")
                .font(.title2)
                .fontWeight(.semibold)
            
            if let error = viewModel.error {
                Text(error)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Button("Try Again", action: viewModel.reset)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
        .padding()
    }
    
    // MARK: - Actions
    
    private func startGame() {
        viewModel.startSession(difficulty: selectedDifficulty)
    }
    
    private func submitAnswer() {
        viewModel.submitAnswer()
    }
    
    private func endGame() {
        viewModel.endSession()
    }
    
    private func playAgain() {
        viewModel.reset()
    }
}

// MARK: - Helper Views

private struct ResultRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
        }
    }
}

// MARK: - Preview

#Preview {
    MentalMathGameView(childId: "child123")
}
