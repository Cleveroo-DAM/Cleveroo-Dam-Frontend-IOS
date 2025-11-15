//
//  CardView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 14/11/2025.
//

import SwiftUI

struct CardView: View {
    let card: Card
    let onTap: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Back of card
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(
                        Image(systemName: "questionmark")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )
                    .opacity(card.isFlipped || card.isMatched ? 0 : 1)
                
                // Front of card
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
                    .overlay(
                        Text(card.cardId)
                            .font(.system(size: min(geometry.size.width, geometry.size.height) * 0.5))
                    )
                    .opacity(card.isFlipped || card.isMatched ? 1 : 0)
                    .rotation3DEffect(
                        .degrees(180),
                        axis: (x: 0, y: 1, z: 0)
                    )
            }
            .rotation3DEffect(
                .degrees(card.isFlipped || card.isMatched ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .opacity(card.isMatched ? 0.3 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: card.isFlipped)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: card.isMatched)
        }
        .aspectRatio(0.7, contentMode: .fit)
        .onTapGesture {
            if !card.isMatched && !card.isFlipped {
                onTap()
            }
        }
    }
}
