//
//  ChildDashboardView.swift
//  Cleveroo
//
//  Dashboard view for children
//

import SwiftUI

struct ChildDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "9C27B0").opacity(0.9),
                    Color(hex: "98FF98").opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Child Dashboard")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Welcome!")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        authViewModel.logout()
                        dismiss()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.1))
                
                Spacer()
                
                // Content
                VStack(spacing: 30) {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 100))
                        .foregroundColor(.white)
                    
                    Text("Welcome to Cleveroo!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Your learning adventure starts here")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        ChildDashboardView()
            .environmentObject(AuthViewModel())
    }
}
