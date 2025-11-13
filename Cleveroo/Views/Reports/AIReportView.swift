//
//  AIReportView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 7/11/2025.
//

import SwiftUI
import Charts

struct AIReportView: View {
    @StateObject private var viewModel = AIReportViewModel()
    @State private var navigateToEvolution = false
    @State private var showTips = false
    @State private var currentTip = ""

    var body: some View {
        NavigationStack {
            ZStack {
                BubbleBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // 🧠 HEADER
                        VStack(spacing: 10) {
                            Text("AI Report Summary 🤖")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Here’s how your little explorer is doing today!")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }
                        
                        // 🟣 MAIN SCORE (Circular Graph)
                        VStack(spacing: 15) {
                            CircularProgressView(value: viewModel.overallScore / 100)
                                .frame(width: 160, height: 160)
                                .padding(.top, 10)
                            
                            Text("Overall Score: \(Int(viewModel.overallScore)) / 100")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        // 📊 SCORES DETAILS
                        VStack(spacing: 12) {
                            ProgressRow(title: "Emotional Intelligence 💖", value: viewModel.emotionalScore)
                            ProgressRow(title: "Memory 🧩", value: viewModel.memoryScore)
                            ProgressRow(title: "Focus 🎯", value: viewModel.focusScore)
                            ProgressRow(title: "Creativity 🎨", value: viewModel.creativityScore)
                        }
                        .padding(.horizontal, 30)
                        
                        Divider().background(Color.white.opacity(0.3)).padding(.horizontal, 40)
                        
                        // 🪄 CLEVEROO ADVICE SECTION
                        VStack(spacing: 10) {
                            Text("Cleveroo’s Advice 🧠")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(viewModel.cleverooAdvice)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: { viewModel.generateNewAdvice() }) {
                                Label("Get Another Tip", systemImage: "sparkles")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 20)
                                    .background(LinearGradient(colors: [Color.purple, Color.pink.opacity(0.9)],
                                                               startPoint: .leading, endPoint: .trailing))
                                    .clipShape(Capsule())
                                    .shadow(radius: 5)
                            }
                            .padding(.top, 5)
                        }
                        .padding()
                        .background(Color.purple.opacity(0.2))
                        .cornerRadius(20)
                        .padding(.horizontal, 30)
                        
                        // 📈 GRAPH
                        VStack(spacing: 15) {
                            Text("Performance Overview 📊")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Chart {
                                BarMark(
                                    x: .value("Category", "Emotional"),
                                    y: .value("Score", viewModel.emotionalScore)
                                )
                                .foregroundStyle(Color.pink)
                                
                                BarMark(
                                    x: .value("Category", "Memory"),
                                    y: .value("Score", viewModel.memoryScore)
                                )
                                .foregroundStyle(Color.mint)
                                
                                BarMark(
                                    x: .value("Category", "Focus"),
                                    y: .value("Score", viewModel.focusScore)
                                )
                                .foregroundStyle(Color.blue)
                                
                                BarMark(
                                    x: .value("Category", "Creativity"),
                                    y: .value("Score", viewModel.creativityScore)
                                )
                                .foregroundStyle(Color.purple)
                            }
                            .frame(height: 200)
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 30)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("AI Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AIEvolutionView(), isActive: $navigateToEvolution) {
                        Button("Evolution") {
                            navigateToEvolution = true
                        }
                        .foregroundColor(.purple)
                        .bold()
                    }
                }
            }
            .onAppear {
                viewModel.generateMockData()
            }
            .alert("💡 AI Tip", isPresented: $showTips) {
                Button("Got it!", role: .cancel) { }
            } message: {
                Text(currentTip)
            }
        }
    }
}

// MARK: - PROGRESS ROW COMPONENT
struct ProgressRow: View {
    let title: String
    let value: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.subheadline)
                Spacer()
                Text("\(Int(value))%")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 8)
                
                Capsule()
                    .fill(LinearGradient(colors: [Color.purple, Color.pink.opacity(0.8)],
                                         startPoint: .leading, endPoint: .trailing))
                    .frame(width: CGFloat(value) * 2.5, height: 8)
                    .animation(.easeInOut(duration: 1.0), value: value)
            }
        }
    }
}

// MARK: - CIRCULAR PROGRESS COMPONENT
struct CircularProgressView: View {
    var value: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 15)
            Circle()
                .trim(from: 0, to: value)
                .stroke(AngularGradient(gradient: Gradient(colors: [Color.purple, Color.pink, Color.yellow]),
                                        center: .center),
                        style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: value)
            
            Text("\(Int(value * 100))%")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

// MARK: - LEGEND ITEM
struct LegendItem: View {
    let color: Color
    let title: String
    
    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

#Preview {
    AIReportView()
}
