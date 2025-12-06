//
//  MiniGamesView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 7/11/2025.
//

import SwiftUI
import Combine

struct MiniGamesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedGame: Game?
    
    let games: [Game] = [
        Game(icon: "🧠", title: "Memory Match", description: "Train your memory by matching pairs of images!", color1: .purple, color2: .pink),
        Game(icon: "🧩", title: "Puzzle Game", description: "Résous des énigmes en déplaçant les pièces !", color1: .blue, color2: .mint),
        Game(icon: "🎨", title: "Coloring Fun", description: "Choose your favorite colors and bring drawings to life!", color1: .orange, color2: .yellow),
        Game(icon: "🔢", title: "Math Challenge", description: "Solve fun math problems to earn stars!", color1: .teal, color2: .green)
    ]
    
    var body: some View {
        ZStack {
            BubbleBackground()
                .ignoresSafeArea()
            
            VStack {
                // Header
                Text("Mini-Games 🎮")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 25) {
                        ForEach(games) { game in
                            Button(action: {
                                selectedGame = game
                            }) {
                                GameCardView(game: game)
                            }
                        }
                    }
                    .padding(.vertical, 30)
                }
            }
        }
        .sheet(item: $selectedGame) { game in
            if game.title == "Memory Match" {
                MemoryGameListView()
                    .environmentObject(authViewModel)
            } else if game.title == "Puzzle Game" {
                ChildPuzzleListView()
                    .environmentObject(authViewModel)
            } else {
                GameDetailView(game: game)
            }
        }
    }
}

// MARK: - Game Model
struct Game: Identifiable {
    var id = UUID()
    var icon: String
    var title: String
    var description: String
    var color1: Color
    var color2: Color
}

// MARK: - Game Card View
struct GameCardView: View {
    var game: Game
    
    var body: some View {
        VStack(spacing: 12) {
            Text(game.icon)
                .font(.largeTitle)
            Text(game.title)
                .font(.headline)
                .foregroundColor(.white)
            Text(game.description)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: [game.color1, game.color2.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(25)
        .shadow(radius: 8)
        .padding(.horizontal, 30)
        .scaleEffect(1.02)
        .animation(.easeInOut(duration: 0.2), value: game.title)
    }
}

// MARK: - Game Detail View
struct GameDetailView: View {
    var game: Game
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            BubbleBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Text(game.icon)
                    .font(.system(size: 70))
                Text(game.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(game.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Back to Games")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [game.color1, game.color2.opacity(0.9)], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 6)
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 50)
            }
            .padding(.top, 80)
        }
    }
}

#Preview {
    MiniGamesView()
}
