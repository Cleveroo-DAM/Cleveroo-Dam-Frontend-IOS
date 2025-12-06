import SwiftUI
import Charts

struct ActivityScoresHistoryView: View {
    let childId: String
    let childName: String
    @ObservedObject var activityVM: ActivityViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isLoading = false
    @State private var completedActivities: [ActivityAssignment] = []
    @State private var selectedFilter: ScoreFilter = .all
    
    enum ScoreFilter: String, CaseIterable {
        case all = "All Activities"
        case highScores = "High Scores (80%+)"
        case lowScores = "Low Scores (<60%)"
        case recent = "Recent"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.92, blue: 0.97),
                        Color(red: 0.98, green: 0.95, blue: 0.99)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Activity Scores")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text(childName)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            // Close button
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .padding()
                        
                        // Statistics Cards
                        if !filteredActivities.isEmpty {
                            HStack(spacing: 12) {
                                ActivityStatCard(
                                    icon: "star.fill",
                                    label: "Average",
                                    value: "\(Int(averageScore))%",
                                    color: .orange
                                )
                                
                                ActivityStatCard(
                                    icon: "arrow.up",
                                    label: "Best",
                                    value: "\(maxScore)%",
                                    color: .green
                                )
                                
                                ActivityStatCard(
                                    icon: "arrow.down",
                                    label: "Lowest",
                                    value: "\(minScore)%",
                                    color: .red
                                )
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.6, green: 0.4, blue: 0.9),
                                Color(red: 0.8, green: 0.6, blue: 0.95)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    
                    // Filter Buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(ScoreFilter.allCases, id: \.self) { filter in
                                FilterButton(
                                    title: filter.rawValue,
                                    isSelected: selectedFilter == filter,
                                    action: { selectedFilter = filter }
                                )
                            }
                        }
                        .padding()
                    }
                    
                    // Chart
                    if !filteredActivities.isEmpty && filteredActivities.count > 1 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Score Progression")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            Chart {
                                ForEach(Array(filteredActivities.enumerated()), id: \.element.id) { index, activity in
                                    if let score = activity.score {
                                        BarMark(
                                            x: .value("Activity", index),
                                            y: .value("Score", score)
                                        )
                                        .foregroundStyle(scoreColor(for: score))
                                    }
                                }
                            }
                            .frame(height: 200)
                            .padding()
                            .background(Color.white.opacity(0.6))
                            .cornerRadius(15)
                            .padding()
                        }
                    }
                    
                    // Activities List
                    if isLoading {
                        VStack {
                            Spacer()
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Loading activities...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.top)
                            Spacer()
                        }
                    } else if filteredActivities.isEmpty {
                        VStack(spacing: 20) {
                            Spacer()
                            Image(systemName: "chart.bar")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("No completed activities yet")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text("Complete activities to see your score history")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.7))
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                        }
                        .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(filteredActivities) { activity in
                                    ActivityScoreRow(activity: activity)
                                }
                            }
                            .padding()
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadActivities()
            }
        }
    }
    
    private var filteredActivities: [ActivityAssignment] {
        let completedOnly = completedActivities.filter { $0.status == "completed" && $0.score != nil }
        
        switch selectedFilter {
        case .all:
            return completedOnly.sorted { ($0.updatedAt ?? "") > ($1.updatedAt ?? "") }
        case .highScores:
            return completedOnly.filter { ($0.score ?? 0) >= 80 }
                .sorted { ($0.score ?? 0) > ($1.score ?? 0) }
        case .lowScores:
            return completedOnly.filter { ($0.score ?? 0) < 60 }
                .sorted { ($0.score ?? 0) < ($1.score ?? 0) }
        case .recent:
            return completedOnly.sorted { ($0.updatedAt ?? "") > ($1.updatedAt ?? "") }
        }
    }
    
    private var averageScore: Double {
        guard !filteredActivities.isEmpty else { return 0 }
        let total = filteredActivities.compactMap { $0.score }.reduce(0, +)
        return Double(total) / Double(filteredActivities.count)
    }
    
    private var maxScore: Int {
        filteredActivities.compactMap { $0.score }.max() ?? 0
    }
    
    private var minScore: Int {
        filteredActivities.compactMap { $0.score }.min() ?? 0
    }
    
    private func loadActivities() {
        isLoading = true
        // Fetch activities for this specific child
        activityVM.fetchActivitiesForChild(childId: childId)
        
        // Use the childAssignments from the view model
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.completedActivities = self.activityVM.childAssignments
            self.isLoading = false
        }
    }
    
    private func scoreColor(for score: Int) -> Color {
        if score >= 80 {
            return .green
        } else if score >= 60 {
            return .orange
        } else {
            return .red
        }
    }
}

// Statistics Card Component
struct ActivityStatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// Filter Button Component
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color(red: 0.7, green: 0.5, blue: 0.95) : Color.white.opacity(0.7))
                .cornerRadius(20)
        }
    }
}

// Activity Score Row Component
struct ActivityScoreRow: View {
    let activity: ActivityAssignment
    
    var body: some View {
        HStack(spacing: 12) {
            // Activity Icon
            Image(systemName: activityIcon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.3))
                .cornerRadius(10)
            
            // Activity Info
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.activityId.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(activity.activityId.type)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Divider()
                        .frame(height: 10)
                    
                    if let date = formatDate(activity.updatedAt) {
                        Text(date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            // Score Badge
            if let score = activity.score {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(score)%")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(scoreLabel(score))
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(10)
                .background(scoreBackgroundColor(score))
                .cornerRadius(10)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.7))
        .cornerRadius(12)
    }
    
    private var activityIcon: String {
        switch activity.activityId.type.lowercased() {
        case "external_game":
            return "gamecontroller.fill"
        case "quiz":
            return "questionmark.circle.fill"
        case "memory_game":
            return "brain.head.profile"
        default:
            return "book.fill"
        }
    }
    
    private var iconColor: Color {
        switch activity.activityId.domain.lowercased() {
        case "cognitive":
            return .blue
        case "social":
            return .pink
        case "emotional":
            return .purple
        case "physical":
            return .orange
        default:
            return .gray
        }
    }
    
    private func scoreBackgroundColor(_ score: Int) -> Color {
        if score >= 80 {
            return .green
        } else if score >= 60 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func scoreLabel(_ score: Int) -> String {
        if score >= 80 {
            return "Excellent"
        } else if score >= 60 {
            return "Good"
        } else {
            return "Needs Work"
        }
    }
    
    private func formatDate(_ dateString: String?) -> String? {
        guard let dateString = dateString else { return nil }
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return nil }
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM d, yyyy"
        return displayFormatter.string(from: date)
    }
}

#Preview {
    ActivityScoresHistoryView(
        childId: "123",
        childName: "John",
        activityVM: ActivityViewModel()
    )
}
