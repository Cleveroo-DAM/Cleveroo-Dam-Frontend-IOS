//
//  RootView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 10/11/2025.
//

import SwiftUI

struct RootView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var isShowingSplash = true
    @State private var isLoggedIn = false

    var body: some View {
        ZStack {
            if isShowingSplash {
                SplashView {
                    // Splash terminé
                    withAnimation {
                        isShowingSplash = false
                    }
                }
            } else {
                if isLoggedIn {
                    MainTabView(viewModel: authViewModel, onLogout: handleLogout)
                } else {
                    RoleSelectionView()
                }
            }
        }
    }

    // MARK: - Actions
    private func handleLogin() {
        isLoggedIn = true
    }

    private func handleLogout() {
        authViewModel.logout()
        isLoggedIn = false
    }
}

#Preview {
    RootView()
}
