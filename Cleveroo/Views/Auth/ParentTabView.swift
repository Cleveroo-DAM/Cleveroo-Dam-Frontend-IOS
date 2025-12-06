//
//  ParentTabView.swift
//  Cleveroo
//
//  Parent main navigation with bottom tab bar
//

import SwiftUI

struct ParentTabView: View {
    @ObservedObject var viewModel: AuthViewModel
    var onLogout: () -> Void
    
    @State private var selectedTab: Tab = .dashboard

    enum Tab {
        case dashboard, progress, assignments, leaderboard, profile
    }

    var body: some View {
        ZStack {
            BubbleBackground().ignoresSafeArea()

            VStack(spacing: 0) {
                // Main content based on selected tab
                ZStack {
                    switch selectedTab {
                    case .dashboard:
                        ParentDashboardView(viewModel: viewModel, onLogout: onLogout)
                    case .progress:
                        NavigationStack {
                            ChildrenProgressView(viewModel: viewModel)
                        }
                    case .assignments:
                        ParentUnifiedAssignmentsView()
                            .environmentObject(viewModel)
                    case .leaderboard:
                        NavigationStack {
                            LeaderboardView()
                                .environmentObject(viewModel)
                        }
                    case .profile:
                        ProfileView(viewModel: viewModel, onLogout: handleLogout)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom Tab Bar
                ParentBottomTabBar(selectedTab: $selectedTab)
            }
        }
        .environmentObject(viewModel)
    }

    private func handleLogout() {
        viewModel.logout()
        onLogout()
    }
}

// MARK: - Parent Bottom Tab Bar
struct ParentBottomTabBar: View {
    @Binding var selectedTab: ParentTabView.Tab

    var body: some View {
        HStack(spacing: 0) {
            tabButton(icon: "house.fill", title: "Dashboard", tab: .dashboard)
            tabButton(icon: "chart.bar.fill", title: "Progress", tab: .progress)
            tabButton(icon: "list.clipboard.fill", title: "Assignments", tab: .assignments)
            tabButton(icon: "trophy.fill", title: "Classement", tab: .leaderboard)
            tabButton(icon: "person.crop.circle.fill", title: "Profile", tab: .profile)
        }
        .padding(.vertical, 10)
        .background(
            LinearGradient(colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.3)],
                           startPoint: .leading, endPoint: .trailing)
                .blur(radius: 8)
                .background(.ultraThinMaterial)
        )
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .padding(.horizontal, 15)
        .padding(.bottom, 5)
        .shadow(radius: 5)
    }

    private func tabButton(icon: String, title: String, tab: ParentTabView.Tab) -> some View {
        Button(action: { selectedTab = tab }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.6))
                    .scaleEffect(selectedTab == tab ? 1.15 : 1.0)
                    .animation(.easeInOut, value: selectedTab)
                Text(title)
                    .font(.caption2)
                    .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ParentTabView(viewModel: AuthViewModel(), onLogout: {})
}
