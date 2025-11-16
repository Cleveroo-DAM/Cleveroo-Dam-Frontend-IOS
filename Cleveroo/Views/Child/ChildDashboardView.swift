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
    @State private var showContent = false
    @State private var selectedAssignment: ActivityAssignment?
    @State private var showGameWebView = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                BubbleBackground().ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 10) {
                        Text("🎮 My Activities")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Play and complete your activities")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // Activities List
                    if activityVM.isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Spacer()
                    } else if activityVM.myAssignments.isEmpty {
                        Spacer()
                        VStack(spacing: 20) {
                            Image(systemName: "tray")
                                .font(.system(size: 80))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("No activities yet")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Your parent will assign activities for you")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(Array(activityVM.myAssignments.enumerated()), id: \.element.id) { index, assignment in
                                    ChildActivityCard(assignment: assignment) {
                                        selectedAssignment = assignment
                                        showGameWebView = true
                                    }
                                    .opacity(showContent ? 1 : 0)
                                    .offset(y: showContent ? 0 : 20)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.1), value: showContent)
                                }
                            }
                            .padding()
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                activityVM.fetchMyActivities()
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

#Preview {
    ChildDashboardView(authVM: AuthViewModel())
}
