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
                if authViewModel.isLoggedIn {
                    if authViewModel.isParent {
                        ParentTabView(viewModel: authViewModel, onLogout: handleLogout)
                    } else {
                        MainTabView(viewModel: authViewModel, onLogout: handleLogout)
                    }
                } else {
                    RoleSelectionView(authViewModel: authViewModel)
                }
            }
        }
    }

    // MARK: - Actions
    private func handleLogout() {
        authViewModel.logout()
    }
}

#Preview {
    RootView()
}
