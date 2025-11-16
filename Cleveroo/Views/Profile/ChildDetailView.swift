//
//  ChildDetailView.swift
//  Cleveroo
//
//  Detailed view of a child's profile and progress
//

import SwiftUI

struct ChildDetailView: View {
    let child: [String: Any]
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            BubbleBackground().ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Child Profile Header
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple, Color.pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Text(genderEmoji)
                                .font(.system(size: 70))
                        }
                        .shadow(color: .white.opacity(0.5), radius: 10)
                        
                        VStack(spacing: 8) {
                            Text(username)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 15) {
                                Label("\(age) years old", systemImage: "birthday.cake")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text("•")
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Text(gender.capitalized)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                    .padding(.top, 30)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : -20)
                    
                    // Account Info Card
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.cyan)
                            Text("Account Information")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        InfoRow(icon: "person.circle", label: "Username", value: username)
                        InfoRow(icon: "number.circle", label: "Age", value: "\(age) years")
                        InfoRow(icon: "person.fill", label: "Gender", value: gender.capitalized)
                        
                        if let createdAt = child["createdAt"] as? String {
                            InfoRow(icon: "calendar", label: "Member Since", value: formatDate(createdAt))
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: showContent)
                    
                    // Progress Overview
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.green)
                            Text("Learning Progress")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        // Memory Games Progress
                        ProgressSection(
                            title: "Memory Games",
                            icon: "brain.head.profile",
                            progress: 0.75,
                            stats: [
                                ("Games Played", "12"),
                                ("Best Score", "100%"),
                                ("Avg Time", "45s")
                            ]
                        )
                        
                        // Learning Activities Progress
                        ProgressSection(
                            title: "Learning Activities",
                            icon: "book.fill",
                            progress: 0.60,
                            stats: [
                                ("Completed", "8"),
                                ("In Progress", "3"),
                                ("Total Time", "2h 15m")
                            ]
                        )
                        
                        // AI Reports Progress
                        ProgressSection(
                            title: "AI Reports Generated",
                            icon: "sparkles",
                            progress: 0.40,
                            stats: [
                                ("Total Reports", "5"),
                                ("Latest", "2 days ago"),
                                ("Avg Rating", "⭐️⭐️⭐️⭐️")
                            ]
                        )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showContent)
                    
                    // Quick Stats Grid
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Quick Stats")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            QuickStatCard(icon: "flame.fill", value: "7", label: "Day Streak", color: .orange)
                            QuickStatCard(icon: "trophy.fill", value: "24", label: "Achievements", color: .yellow)
                            QuickStatCard(icon: "clock.fill", value: "5h 30m", label: "Total Time", color: .blue)
                            QuickStatCard(icon: "target", value: "85%", label: "Accuracy", color: .green)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: showContent)
                    
                    Spacer(minLength: 30)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Child Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                showContent = true
            }
        }
    }
    
    // MARK: - Computed Properties
    private var username: String {
        child["username"] as? String ?? "Unknown"
    }
    
    private var age: Int {
        child["age"] as? Int ?? 0
    }
    
    private var gender: String {
        child["gender"] as? String ?? "male"
    }
    
    private var genderEmoji: String {
        let g = gender.lowercased()
        if g.contains("girl") || g == "female" {
            return "👧"
        } else {
            return "👦"
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .frame(width: 30)
            
            Text(label)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 120, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}

// MARK: - Progress Section
struct ProgressSection: View {
    let title: String
    let icon: String
    let progress: Double
    let stats: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.cyan)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color.cyan, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
            
            // Stats
            HStack(spacing: 15) {
                ForEach(stats, id: \.0) { stat in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stat.0)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                        Text(stat.1)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Quick Stat Card
struct QuickStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ChildDetailView(child: [
            "_id": "123",
            "username": "TestChild",
            "age": 8,
            "gender": "boy",
            "createdAt": "2025-11-16T15:37:26.134Z"
        ])
    }
}
