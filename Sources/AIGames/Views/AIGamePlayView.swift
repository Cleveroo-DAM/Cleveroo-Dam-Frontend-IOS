//
//  AIGamePlayView.swift
//  CleverooDAM
//
//  SwiftUI view for playing AI games
//

import SwiftUI

/// View for playing an AI game
public struct AIGamePlayView: View {
    
    @ObservedObject var viewModel: AIGameViewModel
    @Environment(\.dismiss) private var dismiss
    let game: AIGame
    
    public init(viewModel: AIGameViewModel, game: AIGame) {
        self.viewModel = viewModel
        self.game = game
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [backgroundColorForType(game.gameType).opacity(0.2), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    switch viewModel.gameState {
                    case .browsing, .loading:
                        loadingView
                    case .playing, .challengeCompleted:
                        gameplayView
                    case .levelCompleted:
                        levelCompletedView
                    case .gameCompleted:
                        gameCompletedView
                    case .error:
                        errorView
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
            .navigationTitle(game.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Exit") {
                        exitGame()
                    }
                }
            }
        }
        .onAppear {
            if viewModel.currentSession == nil {
                viewModel.startGame(game)
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(2)
            Text("Starting game...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Gameplay View
    
    private var gameplayView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                gameHeader
                
                // Instructions (first time)
                if viewModel.currentSession?.completedChallenges.isEmpty == true {
                    instructionsCard
                }
                
                // Current Challenge
                if let challenge = viewModel.currentChallenge {
                    challengeCard(challenge)
                }
                
                // Answer Input
                answerSection
                
                // Hints
                if !viewModel.availableHints.isEmpty {
                    hintsSection
                }
                
                // Feedback
                if viewModel.showFeedback {
                    feedbackCard
                }
            }
            .padding()
        }
    }
    
    // MARK: - Game Header
    
    private var gameHeader: some View {
        VStack(spacing: 10) {
            HStack {
                // Level indicator
                VStack(alignment: .leading, spacing: 5) {
                    Text("Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.currentSession?.currentLevel ?? 1)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                // Score
                VStack(alignment: .trailing, spacing: 5) {
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.score)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            
            // Progress bar
            if let level = viewModel.currentLevel {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(Color.blue)
                                .frame(
                                    width: geometry.size.width * (viewModel.progressPercentage / 100),
                                    height: 8
                                )
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
    
    // MARK: - Instructions Card
    
    private var instructionsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("How to Play")
                    .font(.headline)
            }
            
            Text(game.instructions)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
    }
    
    // MARK: - Challenge Card
    
    private func challengeCard(_ challenge: Challenge) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(challenge.prompt)
                .font(.title3)
                .fontWeight(.semibold)
            
            // Multiple choice options
            if challenge.type == .multipleChoice, let options = challenge.options {
                VStack(spacing: 10) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            viewModel.userAnswer = option
                        }) {
                            HStack {
                                Text(option)
                                    .foregroundColor(.primary)
                                Spacer()
                                if viewModel.userAnswer == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(
                                viewModel.userAnswer == option
                                    ? Color.blue.opacity(0.2)
                                    : Color.gray.opacity(0.1)
                            )
                            .cornerRadius(10)
                        }
                        .disabled(viewModel.showFeedback)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
    
    // MARK: - Answer Section
    
    private var answerSection: some View {
        VStack(spacing: 15) {
            if viewModel.currentChallenge?.type != .multipleChoice {
                TextField("Your answer", text: $viewModel.userAnswer)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .disabled(viewModel.showFeedback)
            }
            
            Button(action: submitAnswer) {
                Text("Submit Answer")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        viewModel.userAnswer.isEmpty || viewModel.showFeedback
                            ? Color.gray
                            : Color.green
                    )
                    .cornerRadius(15)
            }
            .disabled(viewModel.userAnswer.isEmpty || viewModel.showFeedback)
        }
    }
    
    // MARK: - Hints Section
    
    private var hintsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Hints Available: \(viewModel.availableHints.count - viewModel.hintsUsed)")
                    .font(.headline)
                
                Spacer()
                
                Button(action: viewModel.showHint) {
                    Text("Show Hint")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
                .disabled(viewModel.hintsUsed >= viewModel.availableHints.count)
            }
            
            if let currentHint = viewModel.currentHint {
                Text(currentHint)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
    
    // MARK: - Feedback Card
    
    private var feedbackCard: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: viewModel.lastAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(viewModel.lastAnswerCorrect ? .green : .red)
                
                VStack(alignment: .leading) {
                    Text(viewModel.lastAnswerCorrect ? "Correct!" : "Not quite")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(viewModel.feedbackMessage)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            viewModel.lastAnswerCorrect
                ? Color.green.opacity(0.1)
                : Color.red.opacity(0.1)
        )
        .cornerRadius(15)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    // MARK: - Level Completed View
    
    private var levelCompletedView: some View {
        VStack(spacing: 30) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Level Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Get ready for the next level")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ProgressView()
        }
        .padding()
    }
    
    // MARK: - Game Completed View
    
    private var gameCompletedView: some View {
        VStack(spacing: 30) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 100))
                .foregroundColor(.yellow)
            
            Text("Congratulations!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("You completed the game!")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 15) {
                StatRow(title: "Final Score", value: "\(viewModel.score)")
                StatRow(
                    title: "Challenges Completed",
                    value: "\(viewModel.currentSession?.completedChallenges.count ?? 0)"
                )
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            
            Button(action: { dismiss() }) {
                Text("Done")
                    .font(.headline)
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
            }
            
            Button("Exit Game") {
                dismiss()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
        .padding()
    }
    
    // MARK: - Actions
    
    private func submitAnswer() {
        viewModel.submitAnswer()
    }
    
    private func exitGame() {
        viewModel.endSession()
        dismiss()
    }
    
    // MARK: - Helper Methods
    
    private func backgroundColorForType(_ type: AIGame.GameType) -> Color {
        switch type {
        case .puzzle: return .orange
        case .memory: return .purple
        case .logic: return .blue
        case .creativity: return .pink
        case .math: return .green
        case .language: return .red
        }
    }
}

// MARK: - Helper Views

private struct StatRow: View {
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
    let viewModel = AIGameViewModel(childId: "child123")
    let game = AIGame(
        title: "Memory Match",
        description: "Test your memory skills",
        gameType: .memory,
        difficulty: .medium,
        ageRange: AIGame.AgeRange(min: 6, max: 10),
        estimatedDuration: 10,
        personalityTraits: [],
        instructions: "Match the pairs of cards",
        content: GameContent(
            levels: [
                GameLevel(
                    levelNumber: 1,
                    title: "Level 1",
                    challenges: [
                        Challenge(
                            prompt: "What is 2 + 2?",
                            type: .multipleChoice,
                            correctAnswer: "4",
                            options: ["2", "3", "4", "5"],
                            hints: ["Add the numbers together"]
                        )
                    ]
                )
            ]
        )
    )
    
    return AIGamePlayView(viewModel: viewModel, game: game)
}
