//
//  MemoryGameSession.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 14/11/2025.
//

import Foundation

struct MemoryGameSession: Codable, Identifiable {
    let id: String
    let userId: String
    let activityId: String  // Stocke l'ID de l'activité
    let activity: MemoryActivity?  // Stocke l'activité complète si populée par le backend
    let status: SessionStatus
    let startTime: Date
    var endTime: Date?
    var score: Int
    var timeSpent: Int
    var pairsFound: Int
    var totalMoves: Int
    var failedAttempts: Int
    var perfectPairs: Int
    var moveHistory: [CardMove]
    var behavioralData: BehavioralData?
    
    // Nom de l'activité pour affichage (extrait de l'activité si disponible)
    var activityName: String {
        activity?.name ?? "Memory Game"
    }
    
    // Difficulté de l'activité pour affichage
    var activityDifficulty: String {
        activity?.difficulty.displayName ?? "Unknown"
    }
    
    enum SessionStatus: String, Codable {
        case IN_PROGRESS = "IN_PROGRESS"
        case COMPLETED = "COMPLETED"
        case ABANDONED = "ABANDONED"
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId, activityId, status, startTime, endTime, score, timeSpent
        case pairsFound, totalMoves, failedAttempts, perfectPairs, moveHistory, behavioralData
    }
    
    // Custom decoder pour gérer activityId comme String OU objet MemoryActivity
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        status = try container.decode(SessionStatus.self, forKey: .status)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decodeIfPresent(Date.self, forKey: .endTime)
        score = try container.decode(Int.self, forKey: .score)
        timeSpent = try container.decode(Int.self, forKey: .timeSpent)
        pairsFound = try container.decode(Int.self, forKey: .pairsFound)
        totalMoves = try container.decode(Int.self, forKey: .totalMoves)
        failedAttempts = try container.decode(Int.self, forKey: .failedAttempts)
        perfectPairs = try container.decode(Int.self, forKey: .perfectPairs)
        moveHistory = try container.decode([CardMove].self, forKey: .moveHistory)
        behavioralData = try container.decodeIfPresent(BehavioralData.self, forKey: .behavioralData)
        
        // Gérer activityId qui peut être String OU objet MemoryActivity
        if let activityObject = try? container.decode(MemoryActivity.self, forKey: .activityId) {
            // C'est un objet complet (populé par le backend)
            activity = activityObject
            activityId = activityObject.id
            print("✅ Decoded activity as object: \(activityObject.name)")
        } else if let activityString = try? container.decode(String.self, forKey: .activityId) {
            // C'est juste un ID
            activityId = activityString
            activity = nil
            print("✅ Decoded activityId as string: \(activityString)")
        } else {
            throw DecodingError.typeMismatch(
                String.self,
                DecodingError.Context(
                    codingPath: container.codingPath + [CodingKeys.activityId],
                    debugDescription: "activityId must be either a String or a MemoryActivity object"
                )
            )
        }
    }
    
    // Encoder normal
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(activityId, forKey: .activityId)
        try container.encode(status, forKey: .status)
        try container.encode(startTime, forKey: .startTime)
        try container.encodeIfPresent(endTime, forKey: .endTime)
        try container.encode(score, forKey: .score)
        try container.encode(timeSpent, forKey: .timeSpent)
        try container.encode(pairsFound, forKey: .pairsFound)
        try container.encode(totalMoves, forKey: .totalMoves)
        try container.encode(failedAttempts, forKey: .failedAttempts)
        try container.encode(perfectPairs, forKey: .perfectPairs)
        try container.encode(moveHistory, forKey: .moveHistory)
        try container.encodeIfPresent(behavioralData, forKey: .behavioralData)
    }
}

struct CardMove: Codable {
    let cardId: String
    let position: Int
    let timestamp: Date
    let matched: Bool
}

struct BehavioralData: Codable {
    let averageResponseTime: Double
    let concentrationScore: Int
    let memoryRetention: Int
    let impulsivityScore: Int
    let strategicThinking: Int
    let frustrationLevel: Int
    let improvementRate: Int
}
