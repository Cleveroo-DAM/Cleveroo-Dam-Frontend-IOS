//
//  ParentDashboardView.swift
//  Cleveroo
//
//  Dashboard view for parents showing their children
//

import SwiftUI

struct ParentDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showAddChild = false
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
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Parent Dashboard")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Manage your children")
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
                
                // Content
                if authViewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Spacer()
                } else if authViewModel.childrenList.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("No Children Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Add your first child to get started")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                    }
                } else {
                    // Children List
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(authViewModel.childrenList, id: \.self) { child in
                                ChildCard(child: child)
                            }
                        }
                        .padding()
                    }
                }
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showAddChild = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color(hex: "9C27B0"))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            authViewModel.fetchChildren()
        }
        .sheet(isPresented: $showAddChild) {
            AddChildView()
                .environmentObject(authViewModel)
                .onDisappear {
                    // Refresh children list when returning
                    authViewModel.fetchChildren()
                }
        }
    }
}

struct ChildCard: View {
    let child: [String: Any]
    
    var username: String {
        child["username"] as? String ?? "Unknown"
    }
    
    var age: Int {
        child["age"] as? Int ?? 0
    }
    
    var gender: String {
        child["gender"] as? String ?? "unknown"
    }
    
    var avatar: String {
        child["avatar"] as? String ?? ""
    }
    
    var genderEmoji: String {
        gender.lowercased() == "male" ? "👦" : "👧"
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 60, height: 60)
                
                if !avatar.isEmpty {
                    // If we have an avatar URL, we could use AsyncImage here
                    Text(genderEmoji)
                        .font(.system(size: 30))
                } else {
                    Text(genderEmoji)
                        .font(.system(size: 30))
                }
            }
            
            // Child Info
            VStack(alignment: .leading, spacing: 4) {
                Text(username)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 10) {
                    Label("\(age) years", systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Label(gender.capitalized, systemImage: gender.lowercased() == "male" ? "figure.child" : "figure.child")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(15)
    }
}

#Preview {
    NavigationStack {
        ParentDashboardView()
            .environmentObject(AuthViewModel())
    }
}
