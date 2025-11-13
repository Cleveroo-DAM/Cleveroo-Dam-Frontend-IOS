//
//  MainTabView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 7/11/2025.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var viewModel: AuthViewModel
    var onLogout: () -> Void
    
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home, ai, games, profile
    }

    var body: some View {
        ZStack {
            BubbleBackground().ignoresSafeArea()

            VStack(spacing: 0) {
                // Contenu principal selon l'onglet sélectionné
                ZStack {
                    switch selectedTab {
                    case .home:
                        HomeView(viewModel: viewModel)
                    case .ai:
                        NavigationStack {
                            AIReportView()
                        }
                    case .games:
                        MiniGamesView()
                    case .profile:
                        ProfileView(viewModel: viewModel) {
                            handleLogout()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom Tab Bar
                BottomTabBar(selectedTab: $selectedTab)
            }
        }
    }

    private func handleLogout() {
        viewModel.logout()
        onLogout()
    }
}

// MARK: - BottomTabBar
struct BottomTabBar: View {
    @Binding var selectedTab: MainTabView.Tab

    var body: some View {
        HStack {
            tabButton(icon: "house.fill", title: "Home", tab: .home)
            tabButton(icon: "brain.head.profile", title: "AI", tab: .ai)
            tabButton(icon: "gamecontroller.fill", title: "Games", tab: .games)
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
        .shadow(radius: 5)
    }

    private func tabButton(icon: String, title: String, tab: MainTabView.Tab) -> some View {
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
    MainTabView(viewModel: AuthViewModel(), onLogout: {})
}
