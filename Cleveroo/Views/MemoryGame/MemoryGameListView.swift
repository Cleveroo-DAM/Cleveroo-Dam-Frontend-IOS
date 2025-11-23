//
//  MemoryGameListView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 14/11/2025.
//

import SwiftUI

struct MemoryGameListView: View {
    @StateObject private var viewModel = MemoryGameViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedActivity: MemoryActivity?
    
    var body: some View {
        ZStack {
            BubbleBackground()
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    Spacer()
                    Text("Memory Match 🧠")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    // Placeholder for symmetry
                    Image(systemName: "chevron.left")
                        .foregroundColor(.clear)
                        .font(.title2)
                }
                .padding()
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 20) {
                        Text("😞")
                            .font(.system(size: 60))
                        Text(error)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Retry") {
                            Task {
                                await viewModel.loadActivities()
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 25) {
                            ForEach(viewModel.activities) { activity in
                                Button(action: {
                                    selectedActivity = activity
                                }) {
                                    ActivityCardView(activity: activity)
                                }
                            }
                        }
                        .padding(.vertical, 30)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.loadActivities()
        }
        .fullScreenCover(item: $selectedActivity) { activity in
            MemoryGamePlayView(activity: activity, viewModel: viewModel)
                .environmentObject(authViewModel)
        }
    }
}

// MARK: - Activity Card View
struct ActivityCardView: View {
    let activity: MemoryActivity
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text(activity.difficulty.icon)
                    .font(.title)
                Text(activity.difficulty.displayName)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            Text(activity.name)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let description = activity.description {
                Text(description)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack {
                Label("\(activity.pairs) pairs", systemImage: "square.grid.3x3")
                Spacer()
                if let timeLimit = activity.timeLimit {
                    Label("\(timeLimit)s", systemImage: "clock")
                }
            }
            .font(.caption)
            .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(difficultyGradient)
        .cornerRadius(20)
        .shadow(radius: 8)
        .padding(.horizontal, 30)
    }
    
    private var difficultyGradient: LinearGradient {
        switch activity.difficulty {
        case .EASY:
            return LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .MEDIUM:
            return LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .HARD:
            return LinearGradient(colors: [.red, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
            .foregroundColor(.white)
            .cornerRadius(15)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
// MARK: - Preview
#Preview {
    MemoryGameListView()
}

