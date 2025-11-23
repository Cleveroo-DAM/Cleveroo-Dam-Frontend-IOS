//
//  AIEvolutionView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 7/11/2025.
//

import SwiftUI
import Charts

struct AIEvolutionView: View {
    @StateObject private var viewModel = AIEvolutionViewModel()
    @State private var selectedTab = "Overall"
    @State private var confettis: [ConfettiParticle] = []
    @State private var showAchievement = false
    @State private var showTips = false
    @State private var currentTip = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                // 🌊 Background
                BubbleBackground()
                    .ignoresSafeArea()

                // 🎊 Confetti Layer
                ForEach(confettis) { confetti in
                    Circle()
                        .fill(confetti.color)
                        .frame(width: confetti.size, height: confetti.size)
                        .position(x: confetti.x, y: confetti.y)
                        .opacity(0.8)
                        .animation(.easeOut(duration: 2), value: confettis)
                }

                VStack(spacing: 20) {
                    // 🧠 Header
                    VStack(spacing: 8) {
                        Text("Cleveroo Evolution 🌈")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Track your progress and celebrate achievements!")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 20)

                    // 🔹 Segmented Control
                    Picker("Chart Type", selection: $selectedTab) {
                        Text("📈 Overall").tag("Overall")
                        Text("🎨 Categories").tag("Categories")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 30)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(15)

                    // 📊 Scrollable Content
                    ScrollView {
                        VStack(spacing: 30) {
                            if selectedTab == "Overall" {
                                overallProgressSection
                            } else {
                                categoryTrendsSection
                            }
                            achievementsSection
                        }
                        .padding()
                    }

                    // 🎉 Confetti & Tips Buttons
                    HStack(spacing: 15) {
                        Button(action: launchConfetti) {
                            Label("Celebrate 🎉", systemImage: "sparkles")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(colors: [.mint, .blue], startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                                .shadow(radius: 6)
                        }

                        Button(action: showRandomTip) {
                            Label("AI Tips 💡", systemImage: "lightbulb")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                                .shadow(radius: 6)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("AI Evolution")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
            /*    ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.yellow)
                    }
                }*/
            }
            .onAppear {
                viewModel.generateMockData()
                withAnimation(.easeInOut(duration: 1.2)) {
                    showAchievement = true
                }
            }
            .alert("💡 AI Tip", isPresented: $showTips) {
                Button("Got it!", role: .cancel) { }
            } message: {
                Text(currentTip)
            }
        }
    }

    // MARK: - Overall Progress
    private var overallProgressSection: some View {
        VStack(spacing: 15) {
            Text("Overall Progress Over 7 Days 📅")
                .font(.headline)
                .foregroundColor(.white)

            Chart(viewModel.overallData) {
                LineMark(x: .value("Day", $0.day),
                         y: .value("Score", $0.score))
                    .foregroundStyle(LinearGradient(colors: [.mint, .blue], startPoint: .leading, endPoint: .trailing))
                    .symbol(Circle())
                    .interpolationMethod(.catmullRom)
            }
            .frame(height: 250)
            .padding(.horizontal, 20)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)

            Text("Average Score: \(Int(viewModel.averageOverallScore)) / 100")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
    }

    // MARK: - Category Trends
    private var categoryTrendsSection: some View {
        VStack(spacing: 15) {
            Text("Category Trends Over 7 Days 🧠")
                .font(.headline)
                .foregroundColor(.white)

            Chart {
                ForEach(viewModel.categoryData.keys.sorted(), id: \.self) { category in
                    if let dataPoints = viewModel.categoryData[category] {
                        ForEach(dataPoints) { point in
                            LineMark(x: .value("Day", point.day),
                                     y: .value("Score", point.score))
                                .foregroundStyle(viewModel.color(for: category))
                                .interpolationMethod(.catmullRom)
                        }
                    }
                }
            }
            .frame(height: 250)
            .padding(.horizontal, 20)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)

            HStack(spacing: 15) {
                EvolutionLegendItem(color: .pink, title: "Emotional 💖")
                EvolutionLegendItem(color: .mint, title: "Memory 🧩")
                EvolutionLegendItem(color: .blue, title: "Focus 🎯")
                EvolutionLegendItem(color: .purple, title: "Creativity 🎨")
            }
        }
    }

    // MARK: - Achievements
    private var achievementsSection: some View {
        VStack(spacing: 15) {
            Text("This Week's Achievements 🏅")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 10)

            ForEach(generateAchievements(), id: \.self) { achievement in
                HStack {
                    Text("✨").font(.title2)
                    Text(achievement)
                        .foregroundColor(.white.opacity(0.9))
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(15)
                .shadow(color: .white.opacity(0.15), radius: 5, x: 0, y: 3)
                .opacity(showAchievement ? 1 : 0)
                .offset(y: showAchievement ? 0 : 15)
                .animation(.easeInOut(duration: 0.8).delay(Double.random(in: 0.1...0.6)), value: showAchievement)
            }
        }
        .padding(.top, 10)
    }

    private func generateAchievements() -> [String] {
        var achievements: [String] = []

        if let topCategory = viewModel.categoryData.max(by: { avgScore(for: $0.value) < avgScore(for: $1.value) })?.key {
            achievements.append("🌟 Amazing progress in \(topCategory)!")
        }

        if viewModel.averageOverallScore > 85 {
            achievements.append("🔥 Outstanding week! You’re a Cleveroo star!")
        } else if viewModel.averageOverallScore > 70 {
            achievements.append("💪 Great consistency! Keep learning and growing.")
        } else {
            achievements.append("🌱 You’re improving! Small steps lead to big wins.")
        }

        achievements.append("🧩 Try new puzzles or games to keep your brain active!")
        return achievements
    }

    private func avgScore(for scores: [DailyScore]) -> Double {
        scores.map(\.score).reduce(0, +) / Double(scores.count)
    }

    // MARK: - Confetti
    private func launchConfetti() {
        confettis = (0..<25).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...UIScreen.main.bounds.height / 2),
                color: [Color.pink, .yellow, .mint, .purple, .blue].randomElement()!,
                size: CGFloat.random(in: 6...14)
            )
        }

        withAnimation(.easeIn(duration: 2)) {
            for index in confettis.indices {
                confettis[index].y += CGFloat.random(in: 300...600)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            confettis.removeAll()
        }
    }

    // MARK: - AI Tips
    private func showRandomTip() {
        let tips = [
            "🧘‍♀️ Try mindfulness 10 min a day to boost focus.",
            "🎵 Play memory games or music to strengthen recall.",
            "📖 Read a chapter daily to stimulate creativity.",
            "💬 Reflect on emotions before reacting — it builds EQ!",
            "☀️ Take walks — nature improves clarity and energy."
        ]
        currentTip = tips.randomElement() ?? "Stay curious and keep learning!"
        showTips = true
    }
}

// MARK: - Confetti Particle
struct ConfettiParticle: Identifiable, Equatable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var color: Color
    var size: CGFloat

    static func == (lhs: ConfettiParticle, rhs: ConfettiParticle) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Legend Item
struct EvolutionLegendItem: View {
    let color: Color
    let title: String

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

#Preview {
    AIEvolutionView()
}

