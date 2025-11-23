//
//  AssignActivityView.swift
//  Cleveroo
//
//  View for parent to assign activities to a child
//

import SwiftUI

struct AssignActivityView: View {
    let childId: String
    @ObservedObject var activityVM: ActivityViewModel
    var onSuccess: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    @State private var showContent = false
    @State private var showConfirmation = false
    @State private var selectedActivity: Activity?
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                BubbleBackground().ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 10) {
                        Text("🎯 Assign Activity")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Choose an activity to assign")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // Activities List
                    if activityVM.isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Spacer()
                    } else if activityVM.allActivities.isEmpty {
                        Spacer()
                        VStack(spacing: 15) {
                            Image(systemName: "tray")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.5))
                            Text("No activities available")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(activityVM.allActivities) { activity in
                                    ActivitySelectionCard(activity: activity) {
                                        selectedActivity = activity
                                        showConfirmation = true
                                    }
                                    .opacity(showContent ? 1 : 0)
                                    .offset(y: showContent ? 0 : 20)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .onAppear {
                activityVM.fetchAllActivities()
                withAnimation(.easeInOut(duration: 0.6)) {
                    showContent = true
                }
            }
            .alert("Assign Activity", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Assign") {
                    assignActivity()
                }
            } message: {
                if let activity = selectedActivity {
                    Text("Are you sure you want to assign '\(activity.title)' to this child?")
                }
            }
            .alert("Success!", isPresented: $showSuccessAlert) {
                Button("OK") {
                    onSuccess()
                    dismiss()
                }
            } message: {
                Text("Activity assigned successfully!")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func assignActivity() {
        guard let activity = selectedActivity else { return }
        
        activityVM.assignActivity(childId: childId, activityId: activity.id) { success, error in
            if success {
                showSuccessAlert = true
            } else {
                errorMessage = error ?? "Failed to assign activity"
                showErrorAlert = true
            }
        }
    }
}

// MARK: - Activity Selection Card
struct ActivitySelectionCard: View {
    let activity: Activity
    let onAssign: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 15) {
                // Icon
                Image(systemName: activityIcon)
                    .font(.system(size: 32))
                    .foregroundColor(domainColor)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(domainColor.opacity(0.2))
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(activity.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    if let description = activity.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                }
                
                Spacer()
            }
            
            // Metadata
            HStack(spacing: 15) {
                Label(activity.type.capitalized, systemImage: "tag.fill")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Label(activity.domain.capitalized, systemImage: "folder.fill")
                    .font(.caption)
                    .foregroundColor(domainColor)
                
                if let minAge = activity.minAge, let maxAge = activity.maxAge {
                    Label("\(minAge)-\(maxAge) yrs", systemImage: "birthday.cake")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            
            // Assign Button
            Button(action: onAssign) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Assign")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [Color.purple, Color.pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(10)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
    }
    
    private var activityIcon: String {
        switch activity.type.lowercased() {
        case "external_game":
            return "gamecontroller.fill"
        case "quiz":
            return "questionmark.circle.fill"
        default:
            return "book.fill"
        }
    }
    
    private var domainColor: Color {
        switch activity.domain.lowercased() {
        case "math":
            return .blue
        case "logic":
            return .purple
        case "literature":
            return .orange
        case "sport":
            return .green
        case "language":
            return .pink
        case "creativity":
            return .yellow
        default:
            return .cyan
        }
    }
}

#Preview {
    AssignActivityView(childId: "123", activityVM: ActivityViewModel(), onSuccess: {})
}
