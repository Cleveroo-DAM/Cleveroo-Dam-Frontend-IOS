//
//  MentalMathGameView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 17/11/2025.
//

//
//  MentalMathGameView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 16/11/2025.
//  Mental Math game interface
//

import SwiftUI

struct MentalMathGameView: View {
    let assignment: ActivityAssignment
    @ObservedObject var activityVM: ActivityViewModel
    var onComplete: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var correctAnswers = 0
    @State private var timeRemaining: Int = 0
    @State private var isGameActive = false
    @State private var showResult = false
    @State private var timer: Timer?
    @State private var totalTimeUsed: Int = 0
    
    var body: some View {
        ZStack {
            BubbleBackground().ignoresSafeArea()
            
            if activityVM.isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    Text("Loading questions...")
                        .foregroundColor(.white)
                        .font(.headline)
                }
            } else if let mathSet = activityVM.currentMentalMathSet {
                if !isGameActive && !showResult {
                    // Start Screen
                    startScreen(mathSet: mathSet)
                } else if showResult {
                    // Result Screen
                    resultScreen(mathSet: mathSet)
                } else {
                    // Game Screen
                    gameScreen(mathSet: mathSet)
                }
            } else {
                // Error State
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    Text("No questions available")
                        .font(.title3)
                        .foregroundColor(.white)
                    
                    Button("Go Back") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
        .navigationTitle("Mental Math")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    timer?.invalidate()
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            loadQuestions()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - Start Screen
    private func startScreen(mathSet: MentalMathSet) -> some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("🧮")
                .font(.system(size: 80))
            
            Text("Mental Math")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(mathSet.title)
                .font(.title2)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 15) {
                MathInfoRow(icon: "questionmark.circle.fill", text: "\(mathSet.questions.count) questions", color: Color.blue)
                MathInfoRow(icon: "clock.fill", text: "\(mathSet.timeLimitSeconds) seconds", color: Color.orange)
                MathInfoRow(icon: "star.fill", text: "Answer quickly!", color: Color.yellow)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.15))
            )
            .padding(.horizontal)
            
            Button(action: startGame) {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                    Text("Start Game")
                }
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.green, Color.blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(color: Color.green.opacity(0.5), radius: 10)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    // MARK: - Game Screen
    private func gameScreen(mathSet: MentalMathSet) -> some View {
        VStack(spacing: 0) {
            // Timer & Progress Header
            HStack {
                Text("⏱️ \(timeRemaining)s")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(timeRemaining <= 10 ? .red : .white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.2))
                    )
                
                Spacer()
                
                Text("\(currentQuestionIndex + 1) / \(mathSet.questions.count)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.2))
                    )
            }
            .padding()
            
            Spacer()
            
            // Question
            if currentQuestionIndex < mathSet.questions.count {
                let question = mathSet.questions[currentQuestionIndex]
                
                VStack(spacing: 40) {
                    // Question Text
                    Text(question.text)
                        .font(.system(size: 56, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(30)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple.opacity(0.5), Color.pink.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                )
                        )
                        .padding(.horizontal)
                    
                    // Options
                    VStack(spacing: 15) {
                        ForEach(0..<question.options.count, id: \.self) { index in
                            optionButton(
                                option: question.options[index],
                                index: index,
                                correctIndex: question.correctIndex,
                                isSelected: selectedAnswer == index
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Option Button
    private func optionButton(option: Int, index: Int, correctIndex: Int, isSelected: Bool) -> some View {
        Button(action: {
            guard selectedAnswer == nil else { return }
            selectAnswer(index, correctIndex: correctIndex)
        }) {
            HStack {
                Text("\(option)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: index == correctIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(index == correctIndex ? .green : .red)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        isSelected
                        ? (index == correctIndex ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                        : Color.white.opacity(0.2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                isSelected
                                ? (index == correctIndex ? Color.green : Color.red)
                                : Color.white.opacity(0.3),
                                lineWidth: 2
                            )
                    )
            )
        }
        .disabled(selectedAnswer != nil)
    }
    
    // MARK: - Result Screen
    private func resultScreen(mathSet: MentalMathSet) -> some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text(resultEmoji)
                .font(.system(size: 100))
            
            Text(resultTitle)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 20) {
                ResultCard(
                    title: "Score",
                    value: "\(accuracy)%",
                    color: accuracyColor,
                    icon: "star.fill"
                )
                ResultCard(
                    title: "Correct Answers",
                    value: "\(correctAnswers) / \(mathSet.questions.count)",
                    color: .blue,
                    icon: "checkmark.circle.fill"
                )
                ResultCard(
                    title: "Time Used",
                    value: "\(totalTimeUsed)s",
                    color: .orange,
                    icon: "clock.fill"
                )
            }
            .padding(.horizontal)
            
            Button(action: {
                onComplete()
                dismiss()
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Done")
                }
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.purple, Color.pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(color: Color.purple.opacity(0.5), radius: 10)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    // MARK: - Helper Properties
    private var accuracy: Int {
        guard let mathSet = activityVM.currentMentalMathSet else { return 0 }
        return Int((Double(correctAnswers) / Double(mathSet.questions.count)) * 100)
    }
    
    private var accuracyColor: Color {
        switch accuracy {
        case 90...100: return .green
        case 70..<90: return .yellow
        default: return .orange
        }
    }
    
    private var resultEmoji: String {
        switch accuracy {
        case 90...100: return "🎉"
        case 70..<90: return "👏"
        case 50..<70: return "💪"
        default: return "📚"
        }
    }
    
    private var resultTitle: String {
        switch accuracy {
        case 90...100: return "Excellent!"
        case 70..<90: return "Great Job!"
        case 50..<70: return "Good Try!"
        default: return "Keep Practicing!"
        }
    }
    
    // MARK: - Game Logic
    private func loadQuestions() {
        activityVM.fetchMentalMathSet(assignmentId: assignment.id) { success, error in
            if success, let mathSet = activityVM.currentMentalMathSet {
                timeRemaining = mathSet.timeLimitSeconds
            } else {
                print("❌ Failed to load questions: \(error ?? "Unknown error")")
            }
        }
    }
    
    private func startGame() {
        guard let mathSet = activityVM.currentMentalMathSet else { return }
        isGameActive = true
        timeRemaining = mathSet.timeLimitSeconds
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame()
            }
        }
    }
    
    private func selectAnswer(_ selected: Int, correctIndex: Int) {
        selectedAnswer = selected
        
        if selected == correctIndex {
            correctAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            selectedAnswer = nil
            
            guard let mathSet = activityVM.currentMentalMathSet else { return }
            
            if currentQuestionIndex < mathSet.questions.count - 1 {
                currentQuestionIndex += 1
            } else {
                endGame()
            }
        }
    }
    
    private func endGame() {
        timer?.invalidate()
        isGameActive = false
        showResult = true
        
        guard let mathSet = activityVM.currentMentalMathSet else { return }
        
        totalTimeUsed = mathSet.timeLimitSeconds - timeRemaining
        
        activityVM.submitMentalMathResult(
            assignmentId: assignment.id,
            correctCount: correctAnswers,
            totalQuestions: mathSet.questions.count,
            timeUsed: totalTimeUsed
        ) { success, error in
            if success {
                print("✅ Results submitted successfully")
            } else {
                print("❌ Failed to submit results: \(error ?? "Unknown error")")
            }
        }
    }
}

// MARK: - Math Info Row
struct MathInfoRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            Text(text)
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Result Card
struct ResultCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color.opacity(0.5), lineWidth: 2)
                )
        )
    }
}

#Preview {
    MentalMathGameView(
        assignment: ActivityAssignment(
            id: "123",
            childId: "child1",
            activityId: ActivityDetails(
                id: "act1",
                title: "Mental Math - Additions",
                description: "Practice additions",
                type: "mental_math",
                domain: "math",
                externalUrl: nil,
                minAge: 5,
                maxAge: 10
            ),
            status: "assigned",
            dueDate: nil,
            score: nil,
            notes: nil,
            createdAt: nil,
            updatedAt: nil
        ),
        activityVM: ActivityViewModel(),
        onComplete: {}
    )
}
