//
//  ChildDashboardView.swift
//  Cleveroo
//
//  Dashboard for child to view and play assigned activities
//

import SwiftUI

struct ChildDashboardView: View {
    @ObservedObject var authVM: AuthViewModel
    @StateObject private var activityVM = ActivityViewModel()
    @StateObject private var gamificationVM = GamificationViewModel()
    @State private var showContent = false
    @State private var selectedAssignment: ActivityAssignment?
    @State private var showGameWebView = false
    @State private var showAllTasks = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                BubbleBackground().ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Text("🎮 My Dashboard")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Track your progress and activities")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 16)
                        
                        // CARD 1: Your Progress
                        if let profile = gamificationVM.profile {
                            YourProgressCard(profile: profile)
                                .padding(.horizontal, 16)
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                                .animation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: showContent)
                        }
                        
                        // CARD 2: My Tasks (Recent)
                        TasksCardView(
                            activityVM: activityVM,
                            authVM: authVM,
                            showContent: showContent,
                            selectedAssignment: $selectedAssignment,
                            showGameWebView: $showGameWebView
                        )
                        .padding(.horizontal, 16)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showContent)
                        
                        // CARD 3: Activities Categories
                        ActivitiesCategoriesCardView(
                            activityVM: activityVM,
                            showContent: showContent
                        )
                        .padding(.horizontal, 16)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: showContent)
                        
                        Spacer()
                            .frame(height: 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Charger les activités
                activityVM.fetchMyActivities()
                
                // Charger le profil de gamification
                if let token = authVM.currentUserToken {
                    gamificationVM.loadMyProfile(token: token)
                }
                
                // Afficher le contenu avec animation
                withAnimation(.easeInOut(duration: 0.6)) {
                    showContent = true
                }
            }
            .sheet(isPresented: $showGameWebView) {
                if let assignment = selectedAssignment {
                    GameWebView(assignment: assignment, activityVM: activityVM) {
                        activityVM.fetchMyActivities()
                    }
                }
            }
        }
    }
    
    private func countByType(_ type: String) -> Int {
        activityVM.myAssignments.filter { $0.activityId.type.lowercased() == type.lowercased() }.count
    }
}

// MARK: - Child Activity Card
struct ChildActivityCard: View {
    let assignment: ActivityAssignment
    let onPlay: () -> Void
    
    var body: some View {
        Button(action: onPlay) {
            HStack(spacing: 15) {
                // Icon
                Image(systemName: activityIcon)
                    .font(.system(size: 36))
                    .foregroundColor(domainColor)
                    .frame(width: 70, height: 70)
                    .background(
                        Circle()
                            .fill(domainColor.opacity(0.2))
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(assignment.activityId.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    if let description = assignment.activityId.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: 10) {
                        StatusBadge(status: assignment.status)
                        
                        if assignment.status.lowercased() != "completed" {
                            HStack(spacing: 4) {
                                Image(systemName: "play.circle.fill")
                                Text("Play Now")
                            }
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.cyan)
                        }
                        
                        if let score = assignment.score {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                Text("\(score)%")
                            }
                            .font(.caption)
                            .foregroundColor(.yellow)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(domainColor.opacity(0.5), lineWidth: 2)
                    )
            )
            .shadow(color: domainColor.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var activityIcon: String {
        switch assignment.activityId.type.lowercased() {
        case "external_game":
            return "gamecontroller.fill"
        case "quiz":
            return "questionmark.circle.fill"
        default:
            return "book.fill"
        }
    }
    
    private var domainColor: Color {
        switch assignment.activityId.domain.lowercased() {
        case "math":
            return .blue
        case "logic":
            return .purple
        case "literature":
            return .orange
        case "sport":
            return .green
        case "language":
            return .pink
        case "creativity":
            return .yellow
        default:
            return .cyan
        }
    }
}

// MARK: - Your Progress Card
struct YourProgressCard: View {
    let profile: GamificationProfile
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("🎯 Your Progress")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Level Badge
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Text("Level \(profile.level)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            }
            
            // XP Progress Bar
            VStack(spacing: 6) {
                HStack {
                    Text("\(profile.xp) XP")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Text("\(profile.xpToNextLevel) XP to Level \(profile.level + 1)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.2))
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color.cyan, Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(profile.progressToNextLevel))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            )
                    }
                }
                .frame(height: 12)
            }
            
            // Quick Stats
            HStack(spacing: 16) {
                QuickStatItem(icon: "🔥", value: "\(profile.currentStreak)", label: "Streak")
                QuickStatItem(icon: "🏅", value: "\(profile.unlockedBadges.count)", label: "Badges")
                
                if let stats = profile.stats, let stars = stats.starsCollected {
                    QuickStatItem(icon: "⭐", value: "\(stars)", label: "Stars")
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.5), Color.cyan.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: Color.purple.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

struct QuickStatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.title3)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Tasks Card View
struct TasksCardView: View {
    let activityVM: ActivityViewModel
    let authVM: AuthViewModel
    let showContent: Bool
    @Binding var selectedAssignment: ActivityAssignment?
    @Binding var showGameWebView: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checklist.checked")
                    .foregroundColor(.blue)
                Text("My Tasks")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text("\(activityVM.myAssignments.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            .foregroundColor(.white)
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            if activityVM.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if activityVM.myAssignments.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.5))
                    Text("No tasks yet")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(activityVM.myAssignments.prefix(3).enumerated()), id: \.element.id) { index, assignment in
                        TaskRowCard(assignment: assignment) {
                            selectedAssignment = assignment
                            showGameWebView = true
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.15 + Double(index) * 0.05), value: showContent)
                    }
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                    .padding(.vertical, 8)
                
                NavigationLink(destination: AllTasksView(authVM: authVM, activityVM: activityVM)) {
                    HStack {
                        Text("View More Tasks")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(.cyan)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showContent)
    }
}

// MARK: - Activities Categories Card View
struct ActivitiesCategoriesCardView: View {
    let activityVM: ActivityViewModel
    let showContent: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "square.grid.2x2")
                    .foregroundColor(.purple)
                Text("Activity Types")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            .foregroundColor(.white)
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ActivityCategoryCard(
                    icon: "🧠",
                    title: "AI Games",
                    count: countByType("external_game"),
                    color: .blue
                )
                
                ActivityCategoryCard(
                    icon: "🔢",
                    title: "Mental Math",
                    count: countByType("mental_math"),
                    color: .orange
                )
                
                ActivityCategoryCard(
                    icon: "🧩",
                    title: "Memory Game",
                    count: countByType("memory_game"),
                    color: .green
                )
                
                ActivityCategoryCard(
                    icon: "📋",
                    title: "Puzzles",
                    count: countByType("puzzle"),
                    color: .pink
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.25), value: showContent)
    }
    
    private func countByType(_ type: String) -> Int {
        activityVM.myAssignments.filter { $0.activityId.type.lowercased() == type.lowercased() }.count
    }
}

// MARK: - Task Row Card
struct TaskRowCard: View {
    let assignment: ActivityAssignment
    let onPlay: () -> Void
    
    var body: some View {
        Button(action: onPlay) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 24))
                    .foregroundColor(statusColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(assignment.activityId.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text(assignment.activityId.type.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        
                        if let score = assignment.score {
                            Text("• \(score)%")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                        }
                    }
                }
                
                Spacer()
                
                if assignment.status.lowercased() != "completed" {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.cyan)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var statusColor: Color {
        switch assignment.status.lowercased() {
        case "completed":
            return .green
        case "in_progress":
            return .orange
        default:
            return .gray
        }
    }
}

// MARK: - Activity Category Card
struct ActivityCategoryCard: View {
    let icon: String
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 32))
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - All Tasks View
struct AllTasksView: View {
    let authVM: AuthViewModel
    let activityVM: ActivityViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                BubbleBackground().ignoresSafeArea()
                
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .foregroundColor(.cyan)
                        }
                        Spacer()
                    }
                    .padding()
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(activityVM.myAssignments, id: \.id) { assignment in
                                TaskRowCard(assignment: assignment) {
                                    // Handle task selection
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("All Tasks")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    ChildDashboardView(authVM: AuthViewModel())
}
