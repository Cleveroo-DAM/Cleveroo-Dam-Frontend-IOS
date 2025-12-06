//
//  MemoryGamePlayView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 14/11/2025.
//

import SwiftUI

struct MemoryGamePlayView: View {
    let activity: MemoryActivity
    @ObservedObject var viewModel: MemoryGameViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingResult = false
    
    var body: some View {
        ZStack {
            BubbleBackground()
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title3)
                            .padding()
                    }
                    Spacer()
                    VStack(spacing: 5) {
                        Text("Score: \(viewModel.score)")
                            .font(.headline)
                        Text("Moves: \(viewModel.moves)")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    Spacer()
                    VStack(spacing: 5) {
                        Text("\(formatTime(viewModel.timeElapsed))")
                            .font(.headline)
                        Text("Time")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding()
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Game Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: activity.cols), spacing: 10) {
                    ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                        CardView(card: card) {
                            viewModel.flipCard(at: index)
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .task {
            guard let userId = authViewModel.currentChildId else {
                print("❌ No child ID available")
                return
            }
            await viewModel.startGame(activity: activity, userId: userId)
        }
        .onChange(of: viewModel.isGameComplete) { isComplete in
            if isComplete {
                showingResult = true
            }
        }
        .fullScreenCover(isPresented: $showingResult) {
            if let session = viewModel.currentSession {
                GameResultView(session: session, onReplay: {
                    showingResult = false
                    Task {
                        guard let userId = authViewModel.currentChildId else { return }
                        viewModel.resetGame()
                        await viewModel.startGame(activity: activity, userId: userId)
                    }
                }, onDismiss: {
                    viewModel.resetGame()
                    dismiss()
                })
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

#Preview {
    let sampleActivity = MemoryActivity(
        id: "preview1",
        name: "Animals Memory",
        description: "Match the animals!",
        difficulty: .EASY,
        rows: 3,
        cols: 4,
        pairs: 6,
        theme: "animals",
        cards: ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊"],
        timeLimit: 120,
        isActive: true
    )
    
    let viewModel = MemoryGameViewModel()
    let authViewModel = AuthViewModel()
    
    return NavigationStack {
        MemoryGamePlayView(activity: sampleActivity, viewModel: viewModel)
            .environmentObject(authViewModel)
    }
}

