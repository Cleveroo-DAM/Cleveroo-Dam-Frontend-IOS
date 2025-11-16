//
//  ContentView.swift
//  Cleveroo
//
//  Main view with navigation
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        LoginView()
            .environmentObject(authViewModel)
    }
}

#Preview {
    ContentView()
}
