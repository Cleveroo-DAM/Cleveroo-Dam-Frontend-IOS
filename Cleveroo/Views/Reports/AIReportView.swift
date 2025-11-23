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
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                // 🌊 Background
                BubbleBackground()
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    // 🧠 Header
                    VStack(spacing: 8) {
                        Text("AI Report Summary 🤖")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Track your progress and celebrate achievements!")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 20)
                    
                    ScrollView {
                        VStack(spacing: 30) {
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
                            
                            // ✨ STRENGTHS SECTION
                            if !viewModel.strengths.isEmpty {
                                VStack(spacing: 10) {
                                    Text("Your Strengths ⭐")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    VStack(spacing: 8) {
                                        ForEach(viewModel.strengths, id: \.self) { strength in
                                            HStack {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                Text(strength)
                                                    .foregroundColor(.white.opacity(0.9))
                                                    .font(.subheadline)
                                                Spacer()
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.green.opacity(0.15))
                                .cornerRadius(20)
                                .padding(.horizontal, 30)
                            }
                            
                            // 📈 AREAS FOR IMPROVEMENT SECTION
                            if !viewModel.areasNeedingImprovement.isEmpty {
                                VStack(spacing: 10) {
                                    Text("Areas to Improve 🎯")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    VStack(spacing: 8) {
                                        ForEach(viewModel.areasNeedingImprovement, id: \.self) { area in
                                            HStack {
                                                Image(systemName: "lightbulb.fill")
                                                    .foregroundColor(.orange)
                                                Text(area)
                                                    .foregroundColor(.white.opacity(0.9))
                                                    .font(.subheadline)
                                                Spacer()
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.orange.opacity(0.15))
                                .cornerRadius(20)
                                .padding(.horizontal, 30)
                            }
                            
                            // 🪄 CLEVEROO ADVICE SECTION
                            VStack(spacing: 10) {
                                Text("Cleveroo's Advice 🧠")
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
                            
                            // 💡 PERSONALISED TIPS SECTION
                            if !viewModel.dailyTips.isEmpty {
                                VStack(spacing: 10) {
                                    Text("Daily Tips 💡")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    VStack(spacing: 8) {
                                        ForEach(viewModel.dailyTips, id: \.self) { tip in
                                            HStack {
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                                Text(tip)
                                                    .foregroundColor(.white.opacity(0.9))
                                                    .font(.caption)
                                                Spacer()
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.yellow.opacity(0.1))
                                .cornerRadius(20)
                                .padding(.horizontal, 30)
                            }
                            
                            // 🎯 RECOMMENDATIONS SECTION
                            if !viewModel.personalisedRecommendations.isEmpty {
                                VStack(spacing: 10) {
                                    Text("Personalised Recommendations 🚀")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    VStack(spacing: 8) {
                                        ForEach(viewModel.personalisedRecommendations, id: \.self) { recommendation in
                                            HStack(alignment: .top) {
                                                Image(systemName: "arrow.right.circle.fill")
                                                    .foregroundColor(.blue)
                                                    .padding(.top, 2)
                                                Text(recommendation)
                                                    .foregroundColor(.white.opacity(0.9))
                                                    .font(.caption)
                                                Spacer()
                                            }
                                            .padding()
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(20)
                                .padding(.horizontal, 30)
                            }
                            
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {                
                ToolbarItem(placement: .principal) {
                    Text("AI Report")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AIEvolutionView()) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("Evolution")
                        }
                        .foregroundColor(.white)
                    }
                }
            }
            .onAppear {
                viewModel.generateMockData()
            }
        }
    }
}

#Preview {
    AIReportView()
}
