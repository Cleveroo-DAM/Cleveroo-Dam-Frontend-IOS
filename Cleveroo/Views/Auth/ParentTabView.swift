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
    @State private var showCreateAssignment = false
    @State private var showAssignmentMenu = false
    @State private var showAssignmentDashboard = false

    enum Tab {
        case dashboard, progress, aiGames, profile
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
                    case .aiGames:
                        NavigationStack {
                            AIGameParentDashboardView()
                                .environmentObject(viewModel)
                        }
                    case .profile:
                        ProfileView(viewModel: viewModel, onLogout: handleLogout)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom Tab Bar
                ParentBottomTabBar(selectedTab: $selectedTab, onCreateAssignment: {
                    print("🎯 Menu Assignment ouvert depuis ParentTabView!")
                    showAssignmentMenu = true
                })
            }
        }
        .environmentObject(viewModel)
        .sheet(isPresented: $showCreateAssignment) {
            CreateAssignmentView(viewModel: AssignmentParentViewModel())
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showAssignmentDashboard) {
            AssignmentParentDashboardView()
                .environmentObject(viewModel)
        }
        .actionSheet(isPresented: $showAssignmentMenu) {
            ActionSheet(
                title: Text("Gestion des Assignments"),
                message: Text("Que souhaitez-vous faire ?"),
                buttons: [
                    .default(Text("🆕 Créer un nouvel assignment")) {
                        showCreateAssignment = true
                    },
                    .default(Text("📋 Voir et valider les assignments")) {
                        showAssignmentDashboard = true
                    },
                    .cancel(Text("Annuler"))
                ]
            )
        }
    }

    private func handleLogout() {
        viewModel.logout()
        onLogout()
    }
}

// MARK: - Parent Bottom Tab Bar
struct ParentBottomTabBar: View {
    @Binding var selectedTab: ParentTabView.Tab
    var onCreateAssignment: (() -> Void)?

    var body: some View {
        HStack(spacing: 0) {
            tabButton(icon: "house.fill", title: "Dashboard", tab: .dashboard)
            tabButton(icon: "chart.bar.fill", title: "Progress", tab: .progress)
            tabButton(icon: "brain.head.profile", title: "AI Games", tab: .aiGames)
            createAssignmentButton()
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
    
    private func createAssignmentButton() -> some View {
        Button(action: {
            print("🎯 BOUTON CRÉER ASSIGNMENT CLIQUÉ DANS PARENT TAB BAR!")
            onCreateAssignment?()
        }) {
            VStack(spacing: 4) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.green)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 28, height: 28)
                    )
                Text("Assignment")
                    .font(.caption2)
                    .foregroundColor(.green)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ParentTabView(viewModel: AuthViewModel(), onLogout: {})
}
