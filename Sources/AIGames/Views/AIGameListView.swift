//
//  AIGameListView.swift
//  CleverooDAM
//
//  SwiftUI view for browsing AI games
//

import SwiftUI

/// View for listing and selecting AI games
public struct AIGameListView: View {
    
    @StateObject private var viewModel: AIGameViewModel
    @State private var selectedGameType: AIGame.GameType?
    @State private var selectedDifficulty: AIGame.Difficulty?
    @State private var showGamePlay = false
    @State private var showGenerateSheet = false
    
    public init(childId: String) {
        _viewModel = StateObject(wrappedValue: AIGameViewModel(childId: childId))
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Filters
                        filterSection
                        
                        // Games Grid
                        if viewModel.availableGames.isEmpty {
                            emptyStateView
                        } else {
                            gamesGrid
                        }
                    }
                    .padding()
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
            .navigationTitle("AI Games")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showGenerateSheet = true }) {
                        Image(systemName: "wand.and.stars")
                    }
                }
            }
            .sheet(isPresented: $showGenerateSheet) {
                GenerateGameSheet(viewModel: viewModel, isPresented: $showGenerateSheet)
            }
            .sheet(isPresented: $showGamePlay) {
                if let game = viewModel.currentGame {
                    AIGamePlayView(viewModel: viewModel, game: game)
                }
            }
            .onAppear {
                if viewModel.availableGames.isEmpty {
                    viewModel.loadGames()
                }
            }
        }
    }
    
    // MARK: - Filter Section
    
    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Filters")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    FilterChip(
                        title: "All Types",
                        isSelected: selectedGameType == nil,
                        action: {
                            selectedGameType = nil
                            applyFilters()
                        }
                    )
                    
                    ForEach(AIGame.GameType.allCases, id: \.self) { type in
                        FilterChip(
                            title: type.rawValue.capitalized,
                            isSelected: selectedGameType == type,
                            action: {
                                selectedGameType = type
                                applyFilters()
                            }
                        )
                    }
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    FilterChip(
                        title: "All Levels",
                        isSelected: selectedDifficulty == nil,
                        action: {
                            selectedDifficulty = nil
                            applyFilters()
                        }
                    )
                    
                    ForEach(AIGame.Difficulty.allCases, id: \.self) { difficulty in
                        FilterChip(
                            title: difficulty.rawValue.capitalized,
                            isSelected: selectedDifficulty == difficulty,
                            action: {
                                selectedDifficulty = difficulty
                                applyFilters()
                            }
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
    
    // MARK: - Games Grid
    
    private var gamesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            ForEach(viewModel.availableGames) { game in
                GameCard(game: game) {
                    selectGame(game)
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No games available")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Generate a new AI game to get started!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showGenerateSheet = true }) {
                Label("Generate Game", systemImage: "wand.and.stars")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Actions
    
    private func applyFilters() {
        viewModel.loadGames(gameType: selectedGameType, difficulty: selectedDifficulty)
    }
    
    private func selectGame(_ game: AIGame) {
        viewModel.currentGame = game
        showGamePlay = true
    }
}

// MARK: - Game Card

private struct GameCard: View {
    let game: AIGame
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                // Icon
                Image(systemName: iconForGameType(game.gameType))
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorForGameType(game.gameType))
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(game.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack {
                        Text(game.difficulty.rawValue.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(5)
                        
                        Spacer()
                        
                        Text("\(game.estimatedDuration)m")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding([.horizontal, .bottom], 10)
            }
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
        }
        .buttonStyle(.plain)
    }
    
    private func iconForGameType(_ type: AIGame.GameType) -> String {
        switch type {
        case .puzzle: return "puzzlepiece.fill"
        case .memory: return "brain.head.profile"
        case .logic: return "lightbulb.fill"
        case .creativity: return "paintbrush.fill"
        case .math: return "number.square.fill"
        case .language: return "text.book.closed.fill"
        }
    }
    
    private func colorForGameType(_ type: AIGame.GameType) -> Color {
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

// MARK: - Filter Chip

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .cornerRadius(20)
        }
    }
}

// MARK: - Generate Game Sheet

private struct GenerateGameSheet: View {
    @ObservedObject var viewModel: AIGameViewModel
    @Binding var isPresented: Bool
    
    @State private var gameType: AIGame.GameType = .puzzle
    @State private var difficulty: AIGame.Difficulty = .medium
    @State private var minAge: Int = 6
    @State private var maxAge: Int = 12
    
    var body: some View {
        NavigationView {
            Form {
                Section("Game Type") {
                    Picker("Type", selection: $gameType) {
                        ForEach(AIGame.GameType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                }
                
                Section("Difficulty") {
                    Picker("Level", selection: $difficulty) {
                        Text("Easy").tag(AIGame.Difficulty.easy)
                        Text("Medium").tag(AIGame.Difficulty.medium)
                        Text("Hard").tag(AIGame.Difficulty.hard)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Age Range") {
                    Stepper("Min Age: \(minAge)", value: $minAge, in: 4...18)
                    Stepper("Max Age: \(maxAge)", value: $maxAge, in: minAge...18)
                }
                
                Section {
                    Button("Generate Game") {
                        generateGame()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .listRowBackground(Color.purple)
                }
            }
            .navigationTitle("Generate AI Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func generateGame() {
        let ageRange = AIGame.AgeRange(min: minAge, max: maxAge)
        viewModel.generateGame(gameType: gameType, difficulty: difficulty, ageRange: ageRange)
        isPresented = false
    }
}

// MARK: - Preview

#Preview {
    AIGameListView(childId: "child123")
}
