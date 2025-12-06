//
//  ParentalControl.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 30/11/2025.
//

import Foundation

// MARK: - Parental Control Models

struct ParentalControl: Codable {
    let childId: String?  // Optional because child endpoint doesn't return it
    var isBlocked: Bool?
    var blockReason: String?
    var allowedTimeSlots: [String]?
    var dailyScreenTimeLimit: Int?
    
    enum CodingKeys: String, CodingKey {
        case childId
        case isBlocked
        case blockReason
        case allowedTimeSlots
        case dailyScreenTimeLimit
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        childId = try container.decodeIfPresent(String.self, forKey: .childId)
        isBlocked = try container.decodeIfPresent(Bool.self, forKey: .isBlocked) ?? false
        blockReason = try container.decodeIfPresent(String.self, forKey: .blockReason)
        allowedTimeSlots = try container.decodeIfPresent([String].self, forKey: .allowedTimeSlots) ?? []
        dailyScreenTimeLimit = try container.decodeIfPresent(Int.self, forKey: .dailyScreenTimeLimit)
    }
}

struct UnblockRequest: Codable, Identifiable {
    let id: String
    let childId: String
    let childUsername: String?
    let childAvatar: String?
    let parentId: String
    let reason: String
    var status: String // "pending", "approved", "rejected"
    var parentResponse: String?
    let createdAt: String?
    let respondedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case childId
        case parentId
        case reason
        case status
        case parentResponse
        case createdAt
        case respondedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        parentId = try container.decode(String.self, forKey: .parentId)
        reason = try container.decode(String.self, forKey: .reason)
        status = try container.decode(String.self, forKey: .status)
        parentResponse = try container.decodeIfPresent(String.self, forKey: .parentResponse)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        respondedAt = try container.decodeIfPresent(String.self, forKey: .respondedAt)
        
        // childId peut être soit une string, soit un objet
        if let childIdString = try? container.decode(String.self, forKey: .childId) {
            childId = childIdString
            childUsername = nil
            childAvatar = nil
        } else if let childObject = try? container.decode(ChildObject.self, forKey: .childId) {
            childId = childObject.id
            childUsername = childObject.username
            childAvatar = childObject.avatar
        } else {
            throw DecodingError.dataCorruptedError(forKey: .childId, in: container, debugDescription: "childId must be either String or Object")
        }
    }
    
    struct ChildObject: Codable {
        let id: String
        let username: String
        let avatar: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case username
            case avatar
        }
    }
}

struct ScreenTimeData: Codable {
    let childId: String
    let totalMinutes: Int
    let hours: Int
    let minutes: Int
}

struct ScreenTimeHistoryEntry: Codable, Identifiable {
    var id: String { date }
    let date: String
    let totalMinutes: Int
    let sessionsCount: Int
}

struct ParentalControlHistory: Codable, Identifiable {
    let id: String
    let parentId: String
    let childId: String
    let action: String
    let metadata: [String: AnyCodable]?
    let performedBy: String?
    let requestStatus: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case parentId
        case childId
        case action
        case metadata
        case performedBy
        case requestStatus
        case createdAt
    }
}

struct RestrictionStatus: Codable {
    let isRestricted: Bool
    let reason: String?
    let canRequestUnblock: Bool?
    let message: String?
}
