//
//  HomeView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 7/11/2025.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: AuthViewModel
    @StateObject private var gamificationVM = GamificationViewModel()
    @StateObject private var activityVM = ActivityViewModel()
    @State private var animateButton = false
    @State private var selectedAssignment: ActivityAssignment?
    @State private var showGameWebView = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Header (centered, no layout shift)
                    VStack(spacing: 10) {
                        Text("Hi, \(viewModel.childUsername.isEmpty ? "Explorer" : viewModel.childUsername)! 👋")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(radius: 2)

                        Text("Welcome back to your Cleveroo world 🌎")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 20)
                    
                    // Progress Summary - Clickable Navigation
                    NavigationLink(destination: GamificationProfileView().environmentObject(viewModel)) {
                        VStack(spacing: 12) {
                            Text("Your Progress")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            if let profile = gamificationVM.profile {
                                ProgressView(value: profile.progressToNextLevel)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                                    .frame(maxWidth: .infinity)
                                    .scaleEffect(y: 1.5)

                                Text("Level \(profile.level) • \(profile.xp) XP • Keep going! 💪")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                            } else {
                                ProgressView(value: 0.0)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                                    .frame(maxWidth: .infinity)
                                    .scaleEffect(y: 1.5)

                                Text("Loading your progress...")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .padding(.vertical, 25)
                        .padding(.horizontal, 20)
                        .background(
                            LinearGradient(
                                colors: [Color.pink.opacity(0.5), Color.purple.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.5), lineWidth: 2))
                        .shadow(color: Color.pink.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 20)
                    
                    // Recent Tasks Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "checklist.checked")
                                .foregroundColor(.blue)
                            Text("Recent Tasks")
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
                                    .font(.system(size: 32))
                                    .foregroundColor(.white.opacity(0.5))
                                Text("No tasks yet")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        } else {
                            VStack(spacing: 10) {
                                ForEach(Array(getSortedAssignments().prefix(5)), id: \.id) { assignment in
                                    HStack(spacing: 12) {
                                        Image(systemName: "checkmark.circle")
                                            .font(.system(size: 20))
                                            .foregroundColor(assignment.status.lowercased() == "completed" ? .green : .gray)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(assignment.activityId.title)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                            
                                            HStack(spacing: 6) {
                                                Text(getActivityTypeIcon(assignment.activityId.type))
                                                Text(assignment.activityId.type.replacingOccurrences(of: "_", with: " ").capitalized)
                                                    .font(.caption2)
                                                    .foregroundColor(.white.opacity(0.7))
                                                
                                                Spacer()
                                                
                                                if let createdAt = assignment.createdAt {
                                                    Text(getRelativeDate(createdAt))
                                                        .font(.caption2)
                                                        .foregroundColor(.white.opacity(0.6))
                                                }
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        if let score = assignment.score {
                                            Text("\(score)%")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                    .padding(10)
                                    .background(Color.white.opacity(0.08))
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // Activity Types Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "square.grid.2x2")
                                .foregroundColor(.purple)
                            Text("Activity Types")
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                            NavigationLink(destination: UnifiedActivitiesView().environmentObject(viewModel)) {
                                HStack(spacing: 4) {
                                    Text("View All")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                                .foregroundColor(.cyan)
                            }
                        }
                        .foregroundColor(.white)
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ActivityTypeCard(
                                icon: "🧠",
                                title: "AI Games",
                                count: countByType("external_game"),
                                color: .blue
                            )
                            
                            ActivityTypeCard(
                                icon: "🔢",
                                title: "Mental Math",
                                count: countByType("mental_math"),
                                color: .orange
                            )
                            
                            ActivityTypeCard(
                                icon: "🧩",
                                title: "Memory Game",
                                count: countByType("memory_game"),
                                color: .green
                            )
                            
                            ActivityTypeCard(
                                icon: "📋",
                                title: "Assignments",
                                count: countByType("assignment"),
                                color: .pink
                            )
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)

                    Spacer()
                    .padding(.bottom, 40)
                }
            }
            .background(BubbleBackground().ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Profile avatar in the top-right
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView(viewModel: viewModel, onLogout: {
                        // Logout action
                        viewModel.logout()
                    }).onDisappear {
                        // Rafraîchir les données quand on revient du ProfileView
                        viewModel.fetchProfile()
                        activityVM.fetchMyActivities()
                    }) {
                        AvatarImageView(avatarUrl: viewModel.avatarURL, size: 40)
                            .overlay(
                                Circle()
                                    .stroke(Color.cyan.opacity(0.6), lineWidth: 2)
                            )
                            .shadow(color: Color.cyan.opacity(0.4), radius: 4)
                    }
                    .accessibilityLabel("Open Profile")
                }
            }
            .onAppear {
                activityVM.fetchMyActivities()
                if let token = viewModel.currentUserToken {
                    gamificationVM.loadMyProfile(token: token)
                }
            }
        }
    }
    
    private func countByType(_ type: String) -> Int {
        activityVM.myAssignments.filter { $0.activityId.type.lowercased() == type.lowercased() }.count
    }
    
    // Trier les tâches par date de création (les plus récentes en premier)
    private func getSortedAssignments() -> [ActivityAssignment] {
        activityVM.myAssignments.sorted { (a1, a2) in
            let date1 = stringToDate(a1.createdAt) ?? Date.distantPast
            let date2 = stringToDate(a2.createdAt) ?? Date.distantPast
            return date1 > date2
        }
    }
    
    // Convertir une String ISO8601 en Date
    private func stringToDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
    
    // Retourner l'icône selon le type d'activité
    private func getActivityTypeIcon(_ type: String) -> String {
        switch type.lowercased() {
        case "external_game", "ai_game":
            return "🧠"
        case "mental_math":
            return "🔢"
        case "memory_game":
            return "🧩"
        case "puzzle":
            return "📋"
        case "assignment":
            return "📝"
        case "quiz":
            return "❓"
        default:
            return "📚"
        }
    }
    
    // Retourner la date relative à partir d'une String ISO8601
    private func getRelativeDate(_ dateString: String) -> String {
        guard let date = stringToDate(dateString) else { return "Unknown" }
        
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let day = components.day, day > 0 {
            return day == 1 ? "1 day ago" : "\(day) days ago"
        } else if let hour = components.hour, hour > 0 {
            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
        } else if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1 min ago" : "\(minute) mins ago"
        } else {
            return "now"
        }
    }
}

// MARK: - Activity Type Card Component
struct ActivityTypeCard: View {
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

// Reusable Button Component
struct HomeActionButton: View {
    var icon: String
    var title: String
    var color1: Color
    var color2: Color

    var body: some View {
        HStack {
            Text(icon).font(.title2)
            Text(title).fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(LinearGradient(colors: [color1, color2.opacity(0.9)],
                                   startPoint: .leading, endPoint: .trailing))
        .foregroundColor(.white)
        .clipShape(Capsule())
        .shadow(radius: 6)
    }
}

#Preview {
    HomeView(viewModel: AuthViewModel())
}
