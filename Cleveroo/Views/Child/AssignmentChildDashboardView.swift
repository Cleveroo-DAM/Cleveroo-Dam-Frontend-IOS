//
//  AssignmentChildDashboardView.swift
//  Cleveroo
//
//  Created by GitHub Copilot on 24/11/2025.
//

import SwiftUI

struct AssignmentChildDashboardView: View {
    @StateObject private var viewModel = AssignmentChildViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab: AssignmentTab = .pending
    @State private var selectedAssignment: Assignment?
    
    enum AssignmentTab: CaseIterable {
        case pending, completed, rejected
        
        var title: String {
            switch self {
            case .pending: return "À faire"
            case .completed: return "Terminés"
            case .rejected: return "À refaire"
            }
        }
        
        var icon: String {
            switch self {
            case .pending: return "clock.fill"
            case .completed: return "checkmark.circle.fill"
            case .rejected: return "arrow.clockwise.circle.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background dégradé
                LinearGradient(
                    colors: [
                        Color.cyan.opacity(0.6),
                        Color.blue.opacity(0.4),
                        Color.purple.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Tout dans un ScrollView pour permettre le scroll complet
                ScrollView {
                    VStack(spacing: 0) {
                        // Header section
                        headerSection
                        
                        // Tab selector
                        tabSelectorSection
                        
                        // Content based on selected tab
                        if viewModel.isLoading {
                            VStack {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.white)
                                Text("Chargement...")
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.top)
                            }
                            .frame(height: 300)
                        } else if filteredAssignments.isEmpty {
                            emptyStateView
                                .frame(height: 300)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredAssignments) { assignment in
                                    AssignmentChildCardView(assignment: assignment) {
                                        selectedAssignment = assignment
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100) // Space for bottom tab bar
                        }
                    }
                }
            }
            .navigationTitle("Mes Tâches")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                setupToken()
                viewModel.loadMyAssignments()
            }
            .sheet(item: $selectedAssignment) { assignment in
                AssignmentChildDetailView(assignment: assignment, viewModel: viewModel)
            }
            .refreshable {
                viewModel.loadMyAssignments()
            }
            .alert("Erreur", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearMessages()
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .alert("Succès", isPresented: .constant(viewModel.successMessage != nil)) {
                Button("OK") {
                    viewModel.clearMessages()
                }
            } message: {
                if let success = viewModel.successMessage {
                    Text(success)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.bullet.clipboard.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
            
            Text("Mes Assignments")
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)
            
            Text("Complète tes tâches et gagne des points !")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            // Statistics
            statisticsView
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2))
        )
        .padding(.horizontal)
    }
    
    private var statisticsView: some View {
        HStack(spacing: 20) {
            AssignmentStatBadge(
                title: "À faire", 
                count: viewModel.pendingAssignments.count,
                color: .orange
            )
            
            AssignmentStatBadge(
                title: "Terminés", 
                count: viewModel.completedAssignments.count,
                color: .green
            )
            
            AssignmentStatBadge(
                title: "Total points", 
                count: totalPoints,
                color: .yellow
            )
        }
    }
    
    private var tabSelectorSection: some View {
        HStack(spacing: 0) {
            ForEach(AssignmentTab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.title3)
                        Text(tab.title)
                            .font(.caption.weight(.medium))
                    }
                    .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedTab == tab ? Color.white.opacity(0.2) : Color.clear)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    // contentSection n'est plus nécessaire car le contenu est maintenant directement dans le ScrollView principal
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: emptyStateIcon)
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.6))
            
            Text(emptyStateTitle)
                .font(.title3.weight(.medium))
                .foregroundColor(.white)
            
            Text(emptyStateMessage)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var filteredAssignments: [Assignment] {
        switch selectedTab {
        case .pending:
            return viewModel.pendingAssignments
        case .completed:
            return viewModel.completedAssignments
        case .rejected:
            return viewModel.rejectedAssignments
        }
    }
    
    private var emptyStateIcon: String {
        switch selectedTab {
        case .pending: return "tray.fill"
        case .completed: return "checkmark.circle.fill"
        case .rejected: return "arrow.clockwise.circle.fill"
        }
    }
    
    private var emptyStateTitle: String {
        switch selectedTab {
        case .pending: return "Aucune tâche en attente"
        case .completed: return "Aucune tâche terminée"
        case .rejected: return "Aucune tâche à refaire"
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedTab {
        case .pending: return "Bravo ! Tu as terminé toutes tes tâches."
        case .completed: return "Les tâches que tu auras terminées apparaîtront ici."
        case .rejected: return "Aucune tâche n'a été rejetée."
        }
    }
    
    private var totalPoints: Int {
        viewModel.completedAssignments.reduce(0) { total, assignment in
            total + (assignment.rewardPoints ?? 0)
        }
    }
    
    private func setupToken() {
        let token = authViewModel.currentUserToken ?? UserDefaults.standard.string(forKey: "jwt") ?? ""
        viewModel.setChildToken(token)
    }
}

struct AssignmentStatBadge: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title3.weight(.bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.6), lineWidth: 1)
                )
        )
    }
}

struct AssignmentChildCardView: View {
    let assignment: Assignment
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                // Type icon and status
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(statusColor.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: assignment.type.icon)
                            .font(.title3)
                            .foregroundColor(statusColor)
                    }
                    
                    Text(assignment.type.displayName)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Assignment info
                VStack(alignment: .leading, spacing: 6) {
                    Text(assignment.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    if let description = assignment.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                    
                    HStack {
                        AssignmentStatusBadge(status: assignment.status)
                        
                        Spacer()
                        
                        if let points = assignment.rewardPoints {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("\(points)")
                                    .foregroundColor(.white)
                            }
                            .font(.caption.weight(.medium))
                        }
                    }
                    
                    // Due date if exists
                    if let dueDate = assignment.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .foregroundColor(.white.opacity(0.6))
                            Text("Avant le \(DateFormatter.shortDate.string(from: dueDate))")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .font(.caption)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var statusColor: Color {
        switch assignment.status {
        case .assigned: return .blue
        case .inProgress: return .orange
        case .submitted: return .purple
        case .approved: return .green
        case .rejected: return .red
        }
    }
}

#Preview {
    AssignmentChildDashboardView()
        .environmentObject(AuthViewModel())
}
