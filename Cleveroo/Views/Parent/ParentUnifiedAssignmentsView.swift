//
//  ParentUnifiedAssignmentsView.swift
//  Cleveroo
//
//  Created by GitHub Copilot on 30/11/2025.
//

import SwiftUI

struct ParentUnifiedAssignmentsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedSegment = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.6),
                        Color.purple.opacity(0.4),
                        Color.pink.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 10) {
                        Text("📋 Gestion des Activités")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Assignments & AI Games")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 15)
                    
                    // Segmented Control
                    Picker("", selection: $selectedSegment) {
                        Text("Assignments").tag(0)
                        Text("AI Games").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 15)
                    .colorMultiply(.white)
                    
                    // Content based on selected segment
                    TabView(selection: $selectedSegment) {
                        // Assignments
                        ParentAssignmentsContent()
                            .environmentObject(authViewModel)
                            .tag(0)
                        
                        // AI Games
                        ParentAIGamesContent()
                            .environmentObject(authViewModel)
                            .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Parent Assignments Content
struct ParentAssignmentsContent: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        AssignmentParentDashboardView()
            .environmentObject(authViewModel)
    }
}

// MARK: - Parent AI Games Content
struct ParentAIGamesContent: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        AIGameParentDashboardView()
            .environmentObject(authViewModel)
    }
}

#Preview {
    ParentUnifiedAssignmentsView()
        .environmentObject(AuthViewModel())
}
