//
//  ChildrenProgressView.swift
//  Cleveroo
//
//  Track children's learning progress
//

import SwiftUI

struct ChildrenProgressView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            BubbleBackground().ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 10) {
                    Text("📊 Children Progress")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Track your children's learning journey")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Children Progress List
                if viewModel.childrenList.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("No children to track")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("Add children to see their progress")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .opacity(showContent ? 1 : 0)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(Array(viewModel.childrenList.enumerated()), id: \.offset) { index, child in
                                Group {
                                    if let childId = child["_id"] as? String,
                                       let childName = child["username"] as? String {
                                        NavigationLink(
                                            destination: ChildAIReportView(
                                                childId: childId,
                                                childName: childName,
                                                authVM: viewModel
                                            )
                                        ) {
                                            ChildProgressCardProfile(child: child)
                                        }
                                    } else {
                                        NavigationLink(destination: ChildDetailView(child: child)) {
                                            ChildProgressCardProfile(child: child)
                                        }
                                    }
                                }
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.1), value: showContent)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchChildren()
            withAnimation(.easeInOut(duration: 0.6)) {
                showContent = true
            }
        }
    }
}

// MARK: - Child Progress Card Profile
struct ChildProgressCardProfile: View {
    let child: [String: Any]
    
    var body: some View {
        VStack(spacing: 15) {
            // Header with child info
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.6), Color.pink.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Text(genderEmoji)
                        .font(.system(size: 35))
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(username)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(age) years old")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Quick Stats
            HStack(spacing: 15) {
                StatBadge(icon: "gamecontroller.fill", value: "12", label: "Games", color: .blue)
                StatBadge(icon: "star.fill", value: "85%", label: "Accuracy", color: .yellow)
                StatBadge(icon: "clock.fill", value: "2h", label: "Time", color: .green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
    }
    
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
        gender.lowercased() == "male" || gender.lowercased() == "boy" || gender.contains("👦") ? "👦" : "👧"
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.1))
        )
    }
}

#Preview {
    ChildrenProgressView(viewModel: AuthViewModel())
}
