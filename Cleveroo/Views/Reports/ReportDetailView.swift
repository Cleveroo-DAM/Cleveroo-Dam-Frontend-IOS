//
//  ReportDetailView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/12/2025.
//

import SwiftUI
import Charts

struct ReportDetailView: View {
    let report: Report
    let token: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Card
                headerCard
                
                // Performance Overview
                performanceOverview
                
                // Activity Statistics
                activityStatistics
                
                // Personality Insights
                if !report.personalityInsights.isEmpty {
                    personalityInsights
                }
                
                // AI Analysis
                aiAnalysisSection
                
                // Recommendations
                if !report.recommendations.isEmpty {
                    recommendationsSection
                }
                
                // Charts
                if let chartData = report.chartData {
                    chartsSection(chartData: chartData)
                }
                
                // Gamification Stats
                gamificationSection
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Détails du rapport")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: 16) {
            // Child Info
            HStack {
                if let avatarURL = report.childId.avatar, let url = URL(string: avatarURL) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Circle().fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text(String(report.childId.username.prefix(1)).uppercased())
                                .font(.title)
                                .foregroundColor(.blue)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(report.childId.username)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(report.periodDisplayName)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(report.formattedDateRange)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(report.performanceEmoji)
                    .font(.system(size: 60))
            }
            
            Divider()
            
            // Title & Summary
            VStack(alignment: .leading, spacing: 8) {
                Text(report.title)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(report.summary)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Performance Overview
    private var performanceOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                Text("Performance globale")
                    .font(.headline)
            }
            
            HStack(spacing: 12) {
                PerformanceCard(
                    title: "Score moyen",
                    value: "\(report.overallAverageScore)%",
                    icon: "star.fill",
                    color: .yellow
                )
                
                PerformanceCard(
                    title: "Activités",
                    value: "\(report.totalActivities)",
                    icon: "gamecontroller.fill",
                    color: .blue
                )
                
                PerformanceCard(
                    title: "Niveau",
                    value: "\(report.currentLevel)",
                    icon: "trophy.fill",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Activity Statistics
    private var activityStatistics: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(.purple)
                Text("Statistiques par activité")
                    .font(.headline)
            }
            
            ActivityStatRow(title: "🎮 Jeux AI", stats: report.aiGames)
            ActivityStatRow(title: "🧠 Jeux de mémoire", stats: report.memoryGames)
            ActivityStatRow(title: "🔢 Calcul mental", stats: report.mentalMath)
            ActivityStatRow(title: "🧩 Puzzles", stats: report.activities)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Personality Insights
    private var personalityInsights: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.purple)
                Text("Insights de personnalité")
                    .font(.headline)
            }
            
            ForEach(report.personalityInsights) { insight in
                PersonalityInsightRow(insight: insight)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - AI Analysis
    private var aiAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text("Analyse AI")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                if !report.strengths.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Points forts", systemImage: "star.fill")
                            .font(.subheadline)
                            .foregroundColor(.green)
                        
                        ForEach(report.strengths, id: \.self) { strength in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(strength)
                                    .font(.body)
                            }
                        }
                    }
                }
                
                if !report.areasForImprovement.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Axes d'amélioration", systemImage: "arrow.up.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                        
                        ForEach(report.areasForImprovement, id: \.self) { area in
                            HStack {
                                Image(systemName: "arrow.up.circle")
                                    .foregroundColor(.orange)
                                Text(area)
                                    .font(.body)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Recommendations
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Recommandations")
                    .font(.headline)
            }
            
            ForEach(report.recommendations) { recommendation in
                RecommendationCard(recommendation: recommendation)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Charts Section
    private func chartsSection(chartData: ChartData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                Text("Graphiques")
                    .font(.headline)
            }
            
            // Scores by Activity
            if !chartData.scoresByActivity.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Scores par activité")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Chart(chartData.scoresByActivity) { item in
                        BarMark(
                            x: .value("Activité", item.activity),
                            y: .value("Score", item.avgScore)
                        )
                        .foregroundStyle(Color.blue.gradient)
                    }
                    .frame(height: 200)
                }
            }
            
            // Time Distribution
            if !chartData.timeDistribution.isEmpty && chartData.timeDistribution.contains(where: { $0.minutes > 0 }) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Répartition du temps (minutes)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Chart(chartData.timeDistribution.filter { $0.minutes > 0 }) { item in
                        SectorMark(
                            angle: .value("Temps", item.minutes),
                            innerRadius: .ratio(0.5)
                        )
                        .foregroundStyle(by: .value("Activité", item.activity))
                    }
                    .frame(height: 200)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Gamification Section
    private var gamificationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("Gamification")
                    .font(.headline)
            }
            
            HStack(spacing: 12) {
                GamificationCard(
                    icon: "star.fill",
                    value: "\(report.xpGained)",
                    label: "XP gagné",
                    color: .yellow
                )
                
                GamificationCard(
                    icon: "flame.fill",
                    value: "\(report.currentStreak)",
                    label: "Série",
                    color: .orange
                )
                
                GamificationCard(
                    icon: "clock.fill",
                    value: "\(report.totalScreenTimeMinutes)",
                    label: "Minutes",
                    color: .blue
                )
            }
            
            if !report.newBadges.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🏆 Nouveaux badges")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(report.newBadges, id: \.self) { badge in
                                BadgeView(badgeName: badge)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Supporting Views

struct PerformanceCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ActivityStatRow: View {
    let title: String
    let stats: ActivityStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                ReportStatItem(label: "Sessions", value: "\(stats.totalSessions)")
                ReportStatItem(label: "Score", value: "\(stats.averageScore)%")
                ReportStatItem(label: "Temps", value: "\(stats.totalTimeMinutes)m")
                ReportStatItem(label: "Taux", value: "\(stats.completionRate)%")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
}

struct ReportStatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundColor(.blue)
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

struct PersonalityInsightRow: View {
    let insight: PersonalityInsight
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.traitDisplayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ProgressView(value: Double(insight.score), total: 100)
                    .tint(scoreColor)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(insight.score)%")
                    .font(.headline)
                    .foregroundColor(scoreColor)
                
                Text(insight.trendEmoji)
                    .font(.title3)
            }
        }
        .padding()
        .background(scoreColor.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var scoreColor: Color {
        switch insight.score {
        case 80...100: return .green
        case 60...79: return .blue
        case 40...59: return .orange
        default: return .red
        }
    }
}

struct RecommendationCard: View {
    let recommendation: AIRecommendation
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: recommendation.categoryIcon)
                .font(.title2)
                .foregroundColor(Color(recommendation.priorityColor))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(recommendation.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(recommendation.description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(recommendation.priority.uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(recommendation.priorityColor))
                .cornerRadius(6)
        }
        .padding()
        .background(Color(recommendation.priorityColor).opacity(0.1))
        .cornerRadius(10)
    }
}

struct GamificationCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct BadgeView: View {
    let badgeName: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "seal.fill")
                .font(.title)
                .foregroundColor(.yellow)
            
            Text(badgeName)
                .font(.caption2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80)
        .padding(8)
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(10)
    }
}

struct ReportDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReportDetailView(
                report: Report(
                    id: "1",
                    childId: Report.ChildInfo(id: "1", username: "Test Child", avatar: nil, age: 8, gender: "boy"),
                    parentId: "parent1",
                    period: "weekly",
                    startDate: Date().addingTimeInterval(-7*24*60*60),
                    endDate: Date(),
                    title: "Excellent progrès cette semaine!",
                    summary: "Ton enfant a fait d'excellents progrès avec une amélioration notable en créativité.",
                    aiGames: ActivityStats(totalSessions: 5, averageScore: 85, totalTimeMinutes: 30, completionRate: 100, recentScores: [80, 85, 90]),
                    memoryGames: ActivityStats(totalSessions: 3, averageScore: 75, totalTimeMinutes: 15, completionRate: 100, recentScores: [70, 75, 80]),
                    mentalMath: ActivityStats(totalSessions: 4, averageScore: 90, totalTimeMinutes: 20, completionRate: 100, recentScores: [85, 90, 95]),
                    activities: ActivityStats(totalSessions: 2, averageScore: 80, totalTimeMinutes: 10, completionRate: 100, recentScores: [75, 85]),
                    totalXP: 500,
                    xpGained: 150,
                    currentLevel: 5,
                    currentStreak: 7,
                    newBadges: ["Créatif", "Champion"],
                    totalScreenTimeMinutes: 75,
                    personalityInsights: [
                        PersonalityInsight(trait: "creativity", score: 85, trend: "increasing"),
                        PersonalityInsight(trait: "focus", score: 75, trend: "stable")
                    ],
                    recommendations: [
                        AIRecommendation(category: "strengths", title: "Excellente créativité", description: "Continue à explorer ton côté créatif!", priority: "high")
                    ],
                    strengths: ["Créativité", "Persévérance"],
                    areasForImprovement: ["Concentration"],
                    overallPerformance: "excellent",
                    chartData: nil,
                    coverImage: nil,
                    createdAt: Date(),
                    updatedAt: Date()
                ),
                token: "dummy-token"
            )
        }
    }
}
