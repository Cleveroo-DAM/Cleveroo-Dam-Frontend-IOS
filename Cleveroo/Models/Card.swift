//
//  Card.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 14/11/2025.
//

import Foundation

struct Card: Identifiable, Equatable {
    let id: UUID
    let cardId: String
    var position: Int
    var isFlipped: Bool
    var isMatched: Bool
    
    init(cardId: String, position: Int) {
        self.id = UUID()
        self.cardId = cardId
        self.position = position
        self.isFlipped = false
        self.isMatched = false
    }
}
