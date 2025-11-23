//
//  GameResultView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 14/11/2025.
//

import SwiftUI

struct GameResultView: View {
    let session: MemoryGameSession
    let onReplay: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            BubbleBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("🎉")
                    .font(.system(size: 80))
                
                Text("Bravo!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    ResultRow(label: "Score", value: "\(session.score)")
                    ResultRow(label: "Moves", value: "\(session.totalMoves)")
                    ResultRow(label: "Time", value: formatTime(session.timeSpent))
                    ResultRow(label: "Pairs Found", value: "\(session.pairsFound)")
                }
                .padding()
                .background(.white.opacity(0.2))
                .cornerRadius(20)
                .padding(.horizontal, 40)
                
                if let behavioral = session.behavioralData {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Behavioral Insights 🧠")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        BehavioralBar(label: "Concentration", value: behavioral.concentrationScore)
                        BehavioralBar(label: "Memory", value: behavioral.memoryRetention)
                        BehavioralBar(label: "Strategy", value: behavioral.strategicThinking)
                    }
                    .padding()
                    .background(.white.opacity(0.2))
                    .cornerRadius(20)
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: onReplay) {
                        Label("Replay", systemImage: "arrow.clockwise")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    
                    Button(action: onDismiss) {
                        Label("Exit", systemImage: "xmark")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
            .padding(.top, 80)
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

struct ResultRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.white.opacity(0.9))
            Spacer()
            Text(value)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .font(.headline)
    }
}

struct BehavioralBar: View {
    let label: String
    let value: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Text("\(value)/100")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.white.opacity(0.3))
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geometry.size.width * CGFloat(value) / 100)
                }
            }
            .frame(height: 8)
        }
    }
}
