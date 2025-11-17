//
//  MentalMathModels.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 17/11/2025.
//

//
//  MentalMathModels.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 16/11/2025.
//  Models for Mental Math activities
//

import Foundation

// Question de calcul mental
struct MentalMathQuestion: Codable, Identifiable {
    var id: String { text } // Utilise le texte comme ID unique
    let text: String
    let options: [Int]
    let correctIndex: Int
    let difficulty: Int
}

// Set de questions (récupéré du backend)
struct MentalMathSet: Codable, Identifiable {
    let id: String
    let activityId: String
    let title: String
    let timeLimitSeconds: Int
    let questions: [MentalMathQuestion]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case activityId
        case title
        case timeLimitSeconds
        case questions
    }
}

// Réponse du backend pour getSetByAssignment
struct MentalMathSetResponse: Codable {
    let assignmentId: String
    let activity: ActivityDetails
    let set: MentalMathSet
}

// Résultat à envoyer au backend
struct MentalMathSubmitRequest: Codable {
    let assignmentId: String
    let correctCount: Int
    let totalQuestions: Int
    let timeUsedSeconds: Int
}

struct MentalMathSubmitResponse: Codable {
    let assignmentId: String
    let score: Int
    let accuracy: Double
}
