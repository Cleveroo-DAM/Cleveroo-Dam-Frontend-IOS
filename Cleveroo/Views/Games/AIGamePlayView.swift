//
//  AIGamePlayView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 24/11/2025.
//

import SwiftUI

struct AIGamePlayView: View {
    @ObservedObject var viewModel: AIGameViewModel
    let game: GeneratedGame
    @Environment(\.dismiss) private var dismiss
    @State private var reactionStartTime: Date?
    @State private var showingExitAlert = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header avec progress et bouton fermer
                gameHeader
                
                // Contenu principal du jeu
                ScrollView {
                    VStack(spacing: 24) {
                        if let currentStep = viewModel.currentStep {
                            GameStepView(
                                step: currentStep,
                                onAnswer: { answer, isCorrect in
                                    viewModel.submitAnswer(
                                        stepId: currentStep.id,
                                        answer: answer,
                                        isCorrect: isCorrect
                                    )
                                },
                                onChoice: { choice in
                                    viewModel.submitChoice(
                                        stepId: currentStep.id,
                                        choice: choice
                                    )
                                },
                                onReaction: { reactionTime in
                                    viewModel.submitReaction(
                                        stepId: currentStep.id,
                                        reactionTime: reactionTime
                                    )
                                }
                            )
                        }
                    }
                    .padding()
                }
                
                // Footer avec informations du jeu
                gameFooter
            }
        }
        .alert("Quitter le jeu ?", isPresented: $showingExitAlert) {
            Button("Annuler", role: .cancel) { }
            Button("Quitter", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Ton progrès sera perdu si tu quittes maintenant.")
        }
    }
    
    private var gameHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { showingExitAlert = true }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(game.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Text("\(viewModel.currentStepIndex + 1)/\(game.spec.steps.count)")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }
            
            // Barre de progression
            ProgressView(value: viewModel.progressPercentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(y: 2)
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.95))
    }
    
    private var gameFooter: some View {
        HStack {
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                Text("~\(viewModel.estimatedTimeRemaining / 60) min restantes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let progress = viewModel.sessionProgress {
                Text("\(progress.percent)% terminé")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.95))
    }
}

struct GameStepView: View {
    let step: GameStep
    let onAnswer: (String, Bool?) -> Void
    let onChoice: (String) -> Void
    let onReaction: (Double) -> Void
    
    @State private var selectedAnswer: String?
    @State private var reactionStartTime: Date?
    @State private var showReactionButton = false
    @State private var textInput = ""
    
    var body: some View {
        VStack(spacing: 24) {
            // Prompt de l'étape
            Text(step.prompt)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            
            // Contenu selon le type d'étape
            switch step.type {
            case .choice:
                choiceView
            case .question:
                questionView
            case .timedReaction:
                timedReactionView
            case .task:
                taskView
            case .miniGame:
                miniGameView
            }
            
            // Timer si limité dans le temps
            if let timeLimit = step.timeLimitSeconds {
                TimerView(timeLimit: timeLimit) {
                    // Temps écoulé - soumettre une réponse vide
                    onAnswer("", false)
                }
            }
        }
    }
    
    private var choiceView: some View {
        VStack(spacing: 12) {
            ForEach(step.options ?? [], id: \.self) { option in
                Button(action: {
                    selectedAnswer = option
                    onChoice(option)
                }) {
                    HStack {
                        Text(option)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        if selectedAnswer == option {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(
                        selectedAnswer == option ? 
                        Color.blue.opacity(0.1) : 
                        Color(.systemGray6)
                    )
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                selectedAnswer == option ? Color.blue : Color.clear,
                                lineWidth: 2
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(selectedAnswer != nil)
            }
        }
    }
    
    private var questionView: some View {
        VStack(spacing: 16) {
            TextField("Ta réponse...", text: $textInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Valider") {
                onAnswer(textInput, nil)
            }
            .buttonStyle(.borderedProminent)
            .disabled(textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
    
    private var timedReactionView: some View {
        VStack(spacing: 20) {
            if showReactionButton {
                Button("APPUIE ICI !") {
                    if let startTime = reactionStartTime {
                        let reactionTime = Date().timeIntervalSince(startTime)
                        onReaction(reactionTime * 1000) // en millisecondes
                    }
                }
                .font(.title.weight(.bold))
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
                .background(Color.red)
                .cornerRadius(16)
                .scaleEffect(1.2)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showReactionButton)
            } else {
                Text("Prépare-toi...")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Circle()
                    .fill(Color.orange)
                    .frame(width: 100, height: 100)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(), value: showReactionButton)
            }
        }
        .onAppear {
            // Délai aléatoire avant d'afficher le bouton
            let delay = Double.random(in: 1.0...4.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                reactionStartTime = Date()
                withAnimation {
                    showReactionButton = true
                }
            }
        }
    }
    
    private var taskView: some View {
        VStack(spacing: 16) {
            Text("Suis les instructions ci-dessus")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Terminé !") {
                onAnswer("completed", true)
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private var miniGameView: some View {
        VStack(spacing: 16) {
            Text("Mini-jeu interactif")
                .font(.headline)
            
            // Placeholder pour un mini-jeu simple
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.2))
                .frame(height: 200)
                .overlay(
                    Text("🎮 Mini-jeu en cours...")
                        .font(.title2)
                )
            
            Button("Continuer") {
                onAnswer("mini_game_completed", true)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct TimerView: View {
    let timeLimit: Int
    let onTimeUp: () -> Void
    
    @State private var timeRemaining: Int
    @State private var timer: Timer?
    
    init(timeLimit: Int, onTimeUp: @escaping () -> Void) {
        self.timeLimit = timeLimit
        self.onTimeUp = onTimeUp
        self._timeRemaining = State(initialValue: timeLimit)
    }
    
    var body: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundColor(timeRemaining <= 5 ? .red : .orange)
            
            Text("\(timeRemaining)s")
                .font(.headline.weight(.bold))
                .foregroundColor(timeRemaining <= 5 ? .red : .primary)
                .animation(.easeInOut, value: timeRemaining)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                onTimeUp()
            }
        }
    }
}

#Preview {
    let mockGame = GeneratedGame(
        id: "1",
        title: "Jeu Test",
        description: "Description test",
        domain: "personality",
        recommendedAgeMin: 6,
        recommendedAgeMax: 10,
        durationSeconds: 300,
        spec: GameSpec(
            steps: [
                GameStep(
                    id: "step1",
                    type: .choice,
                    prompt: "Que préfères-tu ?",
                    options: ["Option A", "Option B", "Option C"],
                    timeLimitSeconds: nil,
                    scoring: nil,
                    metadata: nil
                )
            ],
            metadata: nil
        ),
        meta: nil
    )
    
    AIGamePlayView(viewModel: AIGameViewModel(), game: mockGame)
}