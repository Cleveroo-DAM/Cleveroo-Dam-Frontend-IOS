//
//  ParentChildrenManagementView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 30/11/2025.
//

import SwiftUI

struct ParentChildrenManagementView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var parentalVM = ParentalControlViewModel()
    @State private var selectedChild: Child?
    @State private var showParentalControl = false
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.97, blue: 0.98)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Children List
                    if authVM.childrenList.isEmpty {
                        emptyStateView
                    } else {
                        childrenListSection
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Mes Enfants")
        .navigationBarTitleDisplayMode(.large)
        .task {
            authVM.fetchChildren()
        }
        .sheet(isPresented: $showParentalControl) {
            if let child = selectedChild {
                ParentalControlView(child: child)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 50))
                .foregroundColor(Color(red: 0.4, green: 0.49, blue: 0.92))
            
            Text("Gérer vos enfants")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Cliquez sur un enfant pour gérer ses contrôles parentaux")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.fill.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Aucun enfant")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("Ajoutez un enfant depuis la page d'accueil")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }
    
    // MARK: - Children List Section
    private var childrenListSection: some View {
        VStack(spacing: 15) {
            ForEach(authVM.childrenList.indices, id: \.self) { index in
                let childDict = authVM.childrenList[index]
                if let child = parseChild(from: childDict) {
                    ChildManagementCard(
                        child: child,
                        parentalControl: parentalVM.parentalControl,
                        screenTimeData: parentalVM.screenTimeData,
                        onTap: {
                            selectedChild = child
                            showParentalControl = true
                        }
                    )
                    .task {
                        if let childId = child.id {
                            await parentalVM.loadParentalControl(for: childId)
                            await parentalVM.loadScreenTime(for: childId)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper to parse child from dictionary
    private func parseChild(from dict: [String: Any]) -> Child? {
        guard let id = dict["_id"] as? String ?? dict["id"] as? String,
              let username = dict["username"] as? String,
              let age = dict["age"] as? Int else {
            return nil
        }
        
        let gender = dict["gender"] as? String
        let avatar = dict["avatar"] as? String
        
        return Child(
            id: id,
            username: username,
            age: age,
            gender: gender,
            avatarURL: avatar
        )
    }
}

// MARK: - Child Management Card
struct ChildManagementCard: View {
    let child: Child
    let parentalControl: ParentalControl?
    let screenTimeData: ScreenTimeData?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                // Avatar
                AvatarImageView(avatarUrl: child.avatarURL, size: 60)
                
                // Child Info
                VStack(alignment: .leading, spacing: 5) {
                    Text(child.username)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(child.age) ans")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Status Badge
                    HStack(spacing: 5) {
                        if let control = parentalControl {
                            if control.isBlocked == true {
                                Label("Bloqué", systemImage: "lock.fill")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.red)
                                    .cornerRadius(8)
                            } else {
                                Label("Actif", systemImage: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green)
                                    .cornerRadius(8)
                            }
                        }
                        
                        // Screen Time Badge
                        if let screenTime = screenTimeData {
                            Label("\(screenTime.hours)h\(screenTime.minutes)m", systemImage: "clock.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Helper extension for dictionary
extension Dictionary where Key == String, Value == Any {
    var _id: String? {
        return self["_id"] as? String ?? self["id"] as? String
    }
}

#Preview {
    NavigationStack {
        ParentChildrenManagementView()
            .environmentObject(AuthViewModel())
    }
}
