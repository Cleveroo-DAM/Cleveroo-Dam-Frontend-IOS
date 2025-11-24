//
//  CleverooDAMApp.swift
//  CleverooDAM
//
//  Main app entry point for Cleveroo DAM iOS application
//

import SwiftUI

@main
struct CleverooDAMApp: App {
    
    init() {
        // Configure API client with backend URL
        // In production, this would come from configuration or environment variables
        APIClient.shared.configure(
            baseURL: "https://api.cleveroodam.com",
            authToken: nil // Set after user authentication
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// Main content view with tabs for Mental Math and AI Games
struct ContentView: View {
    
    // Mock child ID - in production this would come from authentication
    private let childId = "demo-child-123"
    
    var body: some View {
        TabView {
            MentalMathGameView(childId: childId)
                .tabItem {
                    Label("Mental Math", systemImage: "brain.head.profile")
                }
            
            AIGameListView(childId: childId)
                .tabItem {
                    Label("AI Games", systemImage: "gamecontroller.fill")
                }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
