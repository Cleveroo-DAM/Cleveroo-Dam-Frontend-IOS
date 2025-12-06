//
//  AIGameSessionView.swift
//  Cleveroo
//
//  Created by GitHub Copilot on 30/11/2025.
//

import SwiftUI

struct AIGameSessionView: View {
    @ObservedObject var viewModel: AIGameViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    let gameId: String
    
    @State private var sessionId: String?
    @State private var showTransition = false
    
    var themeColors: [Color] {
        guard let game = viewModel.currentGame else {
            return [Color(red: 0.6, green: 0.4, blue: 0.8), Color(red: 0.6, green: 0.4, blue: 0.6)]
        }
        
        let domain = game.domain ?? "personality"
        
        switch domain {
        case "creativity":
            return [Color(red: 1.0, green: 0.42, blue: 0.62), Color(red: 0.77, green: 0.27, blue: 0.41), Color(red: 0.55, green: 0.47, blue: 0.9)]
        case "attention":
            return [Color(red: 0.4, green: 0.49, blue: 0.93), Color(red: 0.47, green: 0.29, blue: 0.65)]
        case "personality":
            return [Color(red: 0.94, green: 0.58, blue: 0.98), Color(red: 0.96, green: 0.34, blue: 0.42)]
        case "social":
            return [Color(red: 0.31, green: 0.98, blue: 0.99), Color(red: 0.0, green: 0.95, blue: 0.99)]
        default:
            return [Color(red: 0.61, green: 0.15, blue: 0.69), Color(red: 0.6, green: 1.0, blue: 0.6)]
        }
    }
    
    var body: some View {
        ZStack {
            // Background cohérent avec le reste de l'app
            BubbleBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                if let game = viewModel.currentGame {
                    let totalSteps = game.spec.steps.count
                    EnhancedGameTopBar(
                        title: game.title,
                        currentStep: viewModel.currentStepIndex + 1,
                        totalSteps: totalSteps,
                        onBack: { dismiss() }
                    )
                }
                
                if viewModel.isLoading {
                    EnhancedLoadingScreen(themeColors: themeColors)
                } else if let game = viewModel.currentGame,
                          viewModel.currentStepIndex < game.spec.steps.count {
                    
                    let currentStep = game.spec.steps[viewModel.currentStepIndex]
                    let prompt = currentStep.prompt
                    
                    if showTransition {
                        EnhancedTransitionScreen()
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                renderStepView(
                                    step: currentStep,
                                    prompt: prompt
                                )
                            }
                            .padding(16)
                        }
                    }
                } else if !viewModel.isLoading && viewModel.currentGame != nil {
                    EnhancedGameCompletedScreen(themeColors: themeColors) {
                        if let sid = sessionId {
                            viewModel.completeSession(token: authViewModel.currentUserToken ?? "", sessionId: sid) { _, _ in
                                dismiss()
                            }
                        } else {
                            dismiss()
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            startSession()
        }
    }
    
    private func startSession() {
        // Réinitialiser l'état du jeu pour permettre de rejouer
        viewModel.currentStepIndex = 0
        viewModel.sessionEvents = []
        viewModel.isGameCompleted = false
        viewModel.finalReport = nil
        viewModel.currentSession = nil
        viewModel.currentGame = nil
        
        viewModel.startSession(
            token: authViewModel.currentUserToken ?? "",
            gameId: gameId
        ) { success, sid in
            if success, let sid = sid {
                sessionId = sid
            }
        }
    }
    
    @ViewBuilder
    private func renderStepView(step: GameStep, prompt: String) -> some View {
        let typeFormatted = step.type.rawValue.lowercased()
        
        // Ballon (timed reaction)
        if typeFormatted == "timed_reaction" ||
           prompt.lowercased().contains("balloon") ||
           prompt.lowercased().contains("ballon") ||
           prompt.lowercased().contains("floats up") {
            EnhancedTimedReactionStep(
                step: step,
                themeColors: themeColors,
                stepStartTime: Date(),
                onAnswer: handleAnswer
            )
        }
        // Dessin (creative task)
        else if typeFormatted == "task" && (
            prompt.lowercased().contains("draw") ||
            prompt.lowercased().contains("create") ||
            prompt.lowercased().contains("imagine") ||
            prompt.lowercased().contains("design")
        ) {
            CreativeTaskStep(
                step: step,
                themeColors: themeColors,
                stepStartTime: Date(),
                onAnswer: handleAnswer
            )
        }
        // Comptage interactif (tap stars)
        else if typeFormatted == "task" && (
            prompt.lowercased().contains("tap the screen") ||
            prompt.lowercased().contains("tap each star") ||
            prompt.lowercased().contains("tap for each")
        ) {
            InteractiveStarCountingStep(
                step: step,
                themeColors: themeColors,
                stepStartTime: Date(),
                onAnswer: handleAnswer
            )
        }
        // Comptage avec boutons
        else if typeFormatted == "task" || (
            prompt.lowercased().contains("count") &&
            prompt.lowercased().contains("stars")
        ) {
            EnhancedTaskStep(
                step: step,
                themeColors: themeColors,
                stepStartTime: Date(),
                onAnswer: handleAnswer
            )
        }
        // Question standard
        else {
            EnhancedQuestionStep(
                step: step,
                themeColors: themeColors,
                stepStartTime: Date(),
                onAnswer: handleAnswer
            )
        }
    }
    
    private func handleAnswer(_ event: [String: Any]) {
        showTransition = true
        
        if let sessionId = sessionId {
            viewModel.pushEvents(sessionId: sessionId, events: [event])
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showTransition = false
            viewModel.currentStepIndex += 1
        }
    }
}

// MARK: - Top Bar
struct EnhancedGameTopBar: View {
    let title: String
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.4, green: 0.49, blue: 0.93), Color(red: 0.47, green: 0.29, blue: 0.65)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: Circle()
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 0.18, green: 0.21, blue: 0.28))
                    Text("Question \(currentStep) sur \(totalSteps)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(red: 0.44, green: 0.5, blue: 0.57))
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color.white.opacity(0.95))
            .cornerRadius(20)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(red: 0.88, green: 0.91, blue: 0.94))
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.28, green: 0.73, blue: 0.47), Color(red: 0.22, green: 0.7, blue: 0.66)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(currentStep) / CGFloat(totalSteps))
                }
                .frame(height: 10)
                .cornerRadius(5)
            }
            .frame(height: 10)
        }
        .padding(16)
    }
}

// MARK: - Transition Screen
struct EnhancedTransitionScreen: View {
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [Color(red: 0.28, green: 0.73, blue: 0.47).opacity(0.4), Color.clear]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color(red: 0.28, green: 0.73, blue: 0.47))
                }
                .scaleEffect(scale)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                        scale = 1.2
                    }
                }
                
                Text("Super ! 🎉")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.white)
                
                Text("Question suivante...")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Loading Screen
struct EnhancedLoadingScreen: View {
    let themeColors: [Color]
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: themeColors + [Color.clear]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(rotation))
                        .onAppear {
                            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                                rotation = 360
                            }
                        }
                    
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                
                Text("Chargement...")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Completed Screen
struct EnhancedGameCompletedScreen: View {
    let themeColors: [Color]
    let onFinish: () -> Void
    
    @State private var isVisible = false
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 1.0, green: 0.55, blue: 0.0)]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 5)
                        )
                    
                    Text("🏆")
                        .font(.system(size: 70))
                }
                .frame(width: 140, height: 140)
                
                Text("🎉 BRAVO ! 🎉")
                    .font(.system(size: 44, weight: .black))
                    .tracking(3)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 12) {
                    Text("Tu as terminé !")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(red: 0.18, green: 0.21, blue: 0.28))
                    
                    Text("Tes réponses nous aident à mieux te connaître")
                        .font(.system(size: 15, weight: .regular))
                        .lineSpacing(7)
                        .foregroundColor(Color(red: 0.44, green: 0.5, blue: 0.57))
                        .multilineTextAlignment(.center)
                }
                .padding(28)
                .background(Color.white)
                .cornerRadius(24)
                
                Button(action: onFinish) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32))
                        Text("Terminer")
                            .font(.system(size: 22, weight: .black))
                            .tracking(1.5)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 68)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: themeColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                }
            }
            .padding(32)
            .scaleEffect(scale)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                        scale = 1.0
                    }
                }
            }
        }
    }
}

// MARK: - Animated Background
struct AnimatedGameBackground: View {
    let colors: [Color]
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: colors + colors.reversed()),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Canvas { context, size in
                let width = size.width
                let height = size.height
                let centerX = width / 2
                let centerY = height / 2
                let maxRadius = min(width, height) / 2
                
                for i in 0..<9 {
                    let angle = rotation + (CGFloat(i) * 45.0)
                    let radius = maxRadius * (0.4 + (CGFloat(i) * 0.08))
                    let angleRadians = angle * .pi / 180.0
                    let x = centerX + cos(angleRadians) * radius
                    let y = centerY + sin(angleRadians) * radius
                    
                    var path = Path(ellipseIn: CGRect(x: x - 250, y: y - 250, width: 500, height: 500))
                    context.fill(
                        path,
                        with: .linearGradient(
                            Gradient(colors: [colors[i % colors.count].opacity(0.15), Color.clear]),
                            startPoint: CGPoint(x: x, y: y),
                            endPoint: CGPoint(x: x + 250, y: y + 250)
                        )
                    )
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
        }
    }
}
