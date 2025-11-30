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
    @State private var showCreateAssignment = false

    enum Tab {
        case home, activities, assignments, aiGames, games, gameHistory, profile
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
                    case .activities:
                        ChildDashboardView(authVM: viewModel)
                    case .assignments:
                        NavigationStack {
                            if viewModel.isParent {
                                AssignmentParentDashboardView()
                                    .environmentObject(viewModel)
                            } else {
                                AssignmentChildDashboardView()
                                    .environmentObject(viewModel)
                            }
                        }
                    case .aiGames:
                        NavigationStack {
                            if viewModel.isParent {
                                AIGameParentDashboardView()
                                    .environmentObject(viewModel)
                            } else {
                                AIGamesListView()
                                    .environmentObject(viewModel)
                            }
                        }
                    case .games:
                        NavigationStack {
                            GamesMenuView()
                        }
                    case .gameHistory:
                        NavigationStack {
                            GameHistoryView()
                        }
                    case .profile:
                        ProfileView(viewModel: viewModel) {
                            handleLogout()
                        }
                    }
                    
                    // Bouton flottant pour créer un assignment (parents seulement)
                    if viewModel.isParent {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                    print("🎯 Bouton Créer Assignment cliqué!")
                                    showCreateAssignment = true
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 20, weight: .bold))
                                        Text("Assignment")
                                            .font(.system(size: 15, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 14)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.green, Color.teal],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(30)
                                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                                }
                                .padding(.trailing, 16)
                                .padding(.bottom, 120) // Plus haut au-dessus de la bottom bar
                            }
                        }
                        .allowsHitTesting(true)
                        .zIndex(999) // Force au premier plan
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom Tab Bar
                BottomTabBar(selectedTab: $selectedTab, viewModel: viewModel, onCreateAssignment: {
                    print("🎯 Action créer assignment déclenchée!")
                    showCreateAssignment = true
                })
            }
        }
        .environmentObject(viewModel)  // ✅ Propager l'AuthViewModel à toutes les vues enfants
        .sheet(isPresented: $showCreateAssignment) {
            CreateAssignmentView(viewModel: AssignmentParentViewModel())
                .environmentObject(viewModel)
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
    @ObservedObject var viewModel: AuthViewModel
    var onCreateAssignment: (() -> Void)?

    var body: some View {
        HStack(spacing: 0) {
            tabButton(icon: "house.fill", title: "Home", tab: .home)
            tabButton(icon: "checklist", title: "Tasks", tab: .activities)
            tabButton(icon: "list.clipboard.fill", title: "Assignments", tab: .assignments)
            
            // Afficher le bouton AI seulement pour les parents
            if viewModel.isParent {
                tabButton(icon: "brain.head.profile", title: "AI", tab: .aiGames)
            }
            
            // Bouton spécial pour créer assignment (parents seulement)
            if viewModel.isParent {
                createAssignmentButton()
            }
            
            tabButton(icon: "gamecontroller.fill", title: "Games", tab: .games)
            tabButton(icon: "clock.fill", title: "History", tab: .gameHistory)
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
    
    private func createAssignmentButton() -> some View {
        Button(action: {
            print("🎯 BOUTON CRÉER ASSIGNMENT CLIQUÉ DANS LA BOTTOM BAR!")
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
                Text("Créer")
                    .font(.caption2)
                    .foregroundColor(.green)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    MainTabView(viewModel: AuthViewModel(), onLogout: {})
}
