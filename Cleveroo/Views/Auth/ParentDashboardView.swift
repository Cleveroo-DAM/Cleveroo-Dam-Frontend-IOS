//
//  ParentDashboardView.swift
//  Cleveroo
//
//  Dashboard for parent to view and manage children
//

import SwiftUI

struct ParentDashboardView: View {
    @ObservedObject var viewModel: AuthViewModel
    var onLogout: () -> Void
    
    @State private var showAddChild = false
    @State private var showContent = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                BubbleBackground().ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 10) {
                        Text("👨‍👩‍👧 Parent Dashboard")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Manage your children's accounts")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // Children List
                    if viewModel.childrenList.isEmpty {
                        Spacer()
                        VStack(spacing: 20) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("No children added yet")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Tap the + button to add your first child")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(viewModel.childrenList.indices, id: \.self) { index in
                                    let child = viewModel.childrenList[index]
                                    NavigationLink(destination: ChildDetailView(child: child)) {
                                        ChildCardView(child: child)
                                    }
                                    .opacity(showContent ? 1 : 0)
                                    .offset(y: showContent ? 0 : 20)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.1), value: showContent)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }
                    }
                    
                    Spacer()
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
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(
                                    LinearGradient(
                                        colors: [Color.purple, Color.pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: Color.purple.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .padding(.trailing, 25)
                        .padding(.bottom, 25)
                    }
                }
            }
            .navigationBarHidden(false)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchChildren()
                withAnimation(.easeInOut(duration: 0.6)) {
                    showContent = true
                }
            }
            .sheet(isPresented: $showAddChild) {
                AddChildView(viewModel: viewModel) {
                    showAddChild = false
                    viewModel.fetchChildren()
                }
            }
        }
    }
}

// MARK: - Child Card View
struct ChildCardView: View {
    let child: [String: Any]
    
    var body: some View {
        HStack(spacing: 15) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.6), Color.pink.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                
                Text(genderEmoji)
                    .font(.system(size: 40))
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(username)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack(spacing: 10) {
                    Label("\(age) years", systemImage: "birthday.cake")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(gender.capitalized)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
    }
    
    private var username: String {
        child["username"] as? String ?? "Unknown"
    }
    
    private var age: Int {
        child["age"] as? Int ?? 0
    }
    
    private var gender: String {
        child["gender"] as? String ?? "male"
    }
    
    private var genderEmoji: String {
        gender.lowercased() == "female" ? "👧" : "👦"
    }
}

#Preview {
    ParentDashboardView(viewModel: AuthViewModel(), onLogout: {})
}
