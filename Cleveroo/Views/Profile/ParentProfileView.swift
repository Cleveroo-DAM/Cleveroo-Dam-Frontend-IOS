//  A SUPPRIMER NORMALEMENT
//  ParentProfileView.swift
//  Cleveroo
//
//  Parent Profile View with Navigation Bar
//

import SwiftUI

struct ParentProfileView: View {
    @ObservedObject var viewModel: AuthViewModel
    var onLogout: () -> Void
    
    @State private var showContent = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                BubbleBackground().ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Profile Header
                    VStack(spacing: 15) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple, Color.pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Text("👨‍👩‍👧")
                                .font(.system(size: 50))
                        }
                        .shadow(color: .white.opacity(0.5), radius: 10)
                        
                        Text("Parent Profile")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if !viewModel.parentEmail.isEmpty {
                            VStack(spacing: 5) {
                                Label(viewModel.parentEmail, systemImage: "envelope.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                if !viewModel.parentPhone.isEmpty {
                                    Label(viewModel.parentPhone, systemImage: "phone.fill")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                        }
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : -20)
                    
                    // Quick Actions
                    VStack(spacing: 15) {
                        NavigationLink(destination: ParentDashboardView(viewModel: viewModel, onLogout: onLogout)) {
                            QuickActionCard(
                                icon: "person.3.fill",
                                title: "Children Dashboard",
                                description: "Manage your children",
                                color: .purple
                            )
                        }
                        
                        NavigationLink(destination: AddChildView(viewModel: viewModel, onSuccess: {
                            viewModel.fetchChildren()
                        })) {
                            QuickActionCard(
                                icon: "person.badge.plus",
                                title: "Add Child",
                                description: "Register a new child",
                                color: .blue
                            )
                        }
                        
                        NavigationLink(destination: ChildrenProgressView(viewModel: viewModel)) {
                            QuickActionCard(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Children Progress",
                                description: "Track learning progress",
                                color: .green
                            )
                        }
                        
                        NavigationLink(destination: EditProfileView(viewModel: viewModel)) {
                            QuickActionCard(
                                icon: "person.circle",
                                title: "Edit Profile",
                                description: "Update your information",
                                color: .orange
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    
                    Spacer()
                    
                    // Logout Button
                    Button(action: {
                        onLogout()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.7))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        onLogout()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                        }
                        .foregroundColor(.white)
                    }
                }
            }
            .onAppear {
                viewModel.fetchParentProfile()
                viewModel.fetchChildren()
                withAnimation(.easeInOut(duration: 0.8)) {
                    showContent = true
                }
            }
        }
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
    }
}

#Preview {
    ParentProfileView(viewModel: AuthViewModel(), onLogout: {})
}
