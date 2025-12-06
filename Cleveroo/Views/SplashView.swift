//
//  SplashView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/11/2025.
//

import SwiftUI

struct SplashView: View {
    var onFinish: () -> Void
    @State private var animateLogo = false
    @State private var showStars = false
    @State private var fadeOut = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.purple.opacity(0.9), Color.mint.opacity(0.6)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ZStack {
                Image("Cleveroo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .scaleEffect(animateLogo ? 1.1 : 0.5)
                    .opacity(animateLogo ? 1 : 0)
                    .shadow(color: .white.opacity(0.5), radius: 20)
                
                if showStars {
                    ForEach(0..<6, id: \.self) { i in
                        StarView(delay: Double(i) * 0.2)
                    }
                }
            }
            .opacity(fadeOut ? 0 : 1)
        }
        .onAppear {
            startAnimationSequence()
        }
    }

    func startAnimationSequence() {
        withAnimation { animateLogo = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { showStars = true }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 1.0)) { fadeOut = true }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            onFinish()
        }
    }
}

struct StarView: View {
    @State private var animate = false
    let delay: Double

    var body: some View {
        Image(systemName: "star.fill")
            .foregroundColor(.yellow)
            .opacity(animate ? 0 : 0.9)
            .scaleEffect(animate ? 0.2 : 1.0)
            .rotationEffect(.degrees(animate ? 360 : 0))
            .offset(x: CGFloat.random(in: -120...120),
                    y: CGFloat.random(in: -100...100))
            .animation(Animation.easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true)
                .delay(delay), value: animate)
            .onAppear { animate = true }
    }
}

#Preview {
    SplashView { }
}
