//
//  SharedStyles.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/11/2025.
//

import Foundation

import SwiftUI

// 🌸 Modèle de bulle
struct Bubble: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var speed: Double
    
    static func generateRandom(count: Int) -> [Bubble] {
        (0..<count).map { _ in
            Bubble(position: CGPoint(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
            ),
            size: CGFloat.random(in: 20...80),
            color: [Color.purple, Color.pink, Color.blue, Color.mint].randomElement()!,
            speed: Double.random(in: 4...8))
        }
    }
    
    mutating func animate() {
        position.x += CGFloat.random(in: -40...40)
        position.y += CGFloat.random(in: -60...60)
    }
}


struct ChildFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .foregroundColor(.white)
            .font(.system(size: 15))
    }
}

struct BubbleBackground: View {
    @State private var move = false
    
    var body: some View {
        ZStack {
            // Même dégradé que le SplashView - violet vers mint
            LinearGradient(colors: [Color.purple.opacity(0.9), Color.mint.opacity(0.6)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            
            // Bulles blanches subtiles pour l'effet animé
            ForEach(0..<12, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.05...0.15)))
                    .frame(width: CGFloat.random(in: 40...120))
                    .offset(x: CGFloat.random(in: -180...180),
                            y: move ? CGFloat.random(in: -400...400) : CGFloat.random(in: 400...800))
                    .animation(Animation.linear(duration: Double.random(in: 15...25))
                        .repeatForever(autoreverses: false), value: move)
            }
        }
        .onAppear { move.toggle() }
    }
}

