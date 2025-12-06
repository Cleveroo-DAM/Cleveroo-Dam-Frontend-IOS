//
//  Assignment.swift
//  Cleveroo
//
//  Created by GitHub Copilot on 24/11/2025.
//

import Foundation

// MARK: - Assignment Models

enum AssignmentType: String, CaseIterable, Codable {
    case drawing = "drawing"
    case homework = "homework" 
    case chore = "chore"
    case reading = "reading"
    case craft = "craft"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .drawing: return "Dessin"
        case .homework: return "Devoir"
        case .chore: return "Corvée"
        case .reading: return "Lecture"
        case .craft: return "Bricolage"
        case .other: return "Autre"
        }
    }
    
    var icon: String {
        switch self {
        case .drawing: return "paintbrush.fill"
        case .homework: return "book.fill"
        case .chore: return "house.fill"
        case .reading: return "text.book.closed.fill"
        case .craft: return "scissors"
        case .other: return "square.grid.2x2.fill"
        }
    }
}

enum AssignmentStatus: String, CaseIterable, Codable {
    case assigned = "assigned"
    case inProgress = "in_progress"
    case submitted = "submitted"
    case approved = "approved"
    case rejected = "rejected"
    
    var displayName: String {
        switch self {
        case .assigned: return "Assigné"
        case .inProgress: return "En cours"
        case .submitted: return "Soumis"
        case .approved: return "Approuvé"
        case .rejected: return "Rejeté"
        }
    }
    
    var color: String {
        switch self {
        case .assigned: return "blue"
        case .inProgress: return "orange"
        case .submitted: return "purple"
        case .approved: return "green"
        case .rejected: return "red"
        }
    }
}

struct Assignment: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let type: AssignmentType
    let status: AssignmentStatus
    let parentId: String
    let childId: String
    let dueDate: Date?
    let rewardPoints: Int?
    let submissionPhotos: [String]
    let submissionComment: String?
    let submittedAt: Date?
    let parentFeedback: String?
    let reviewedAt: Date?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, description, type, status, parentId, childId, dueDate, rewardPoints
        case submissionPhotos, submissionComment, submittedAt, parentFeedback, reviewedAt
        case createdAt, updatedAt
    }
    
    // Custom Decodable to handle childId and parentId as either String or Object with _id
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        type = try container.decode(AssignmentType.self, forKey: .type)
        status = try container.decode(AssignmentStatus.self, forKey: .status)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        rewardPoints = try container.decodeIfPresent(Int.self, forKey: .rewardPoints)
        submissionPhotos = try container.decodeIfPresent([String].self, forKey: .submissionPhotos) ?? []
        submissionComment = try container.decodeIfPresent(String.self, forKey: .submissionComment)
        submittedAt = try container.decodeIfPresent(Date.self, forKey: .submittedAt)
        parentFeedback = try container.decodeIfPresent(String.self, forKey: .parentFeedback)
        reviewedAt = try container.decodeIfPresent(Date.self, forKey: .reviewedAt)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        
        // Handle parentId - decode as AnyCodable to handle both String and Object
        let parentIdValue = try container.decode(AnyCodable.self, forKey: .parentId)
        switch parentIdValue {
        case .string(let str):
            parentId = str
        case .dictionary(let dict):
            // Extract _id from the dictionary
            if let idValue = dict["_id"], case .string(let id) = idValue {
                parentId = id
            } else {
                throw DecodingError.dataCorruptedError(forKey: .parentId, in: container, debugDescription: "Cannot extract _id from parentId object")
            }
        default:
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(codingPath: container.codingPath + [CodingKeys.parentId], debugDescription: "parentId must be String or Object", underlyingError: nil))
        }
        
        // Handle childId - decode as AnyCodable to handle both String and Object
        let childIdValue = try container.decode(AnyCodable.self, forKey: .childId)
        switch childIdValue {
        case .string(let str):
            childId = str
        case .dictionary(let dict):
            // Extract _id from the dictionary
            if let idValue = dict["_id"], case .string(let id) = idValue {
                childId = id
            } else {
                throw DecodingError.dataCorruptedError(forKey: .childId, in: container, debugDescription: "Cannot extract _id from childId object")
            }
        default:
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(codingPath: container.codingPath + [CodingKeys.childId], debugDescription: "childId must be String or Object", underlyingError: nil))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(type, forKey: .type)
        try container.encode(status, forKey: .status)
        try container.encode(parentId, forKey: .parentId)
        try container.encode(childId, forKey: .childId)
        try container.encodeIfPresent(dueDate, forKey: .dueDate)
        try container.encodeIfPresent(rewardPoints, forKey: .rewardPoints)
        try container.encode(submissionPhotos, forKey: .submissionPhotos)
        try container.encodeIfPresent(submissionComment, forKey: .submissionComment)
        try container.encodeIfPresent(submittedAt, forKey: .submittedAt)
        try container.encodeIfPresent(parentFeedback, forKey: .parentFeedback)
        try container.encodeIfPresent(reviewedAt, forKey: .reviewedAt)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}

// Helper struct to decode childId object from backend
private struct ChildIdObject: Codable {
    let id: String
    let age: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case age
    }
}

// MARK: - Request Models

struct CreateAssignmentRequest: Codable {
    let childId: String
    let title: String
    let description: String?
    let type: AssignmentType
    let dueDate: Date?
    let rewardPoints: Int?
}

struct UpdateAssignmentRequest: Codable {
    let title: String?
    let description: String?
    let type: AssignmentType?
    let dueDate: Date?
    let rewardPoints: Int?
}

struct SubmitAssignmentRequest: Codable {
    let submissionPhotos: [String] // Base64 encoded images
    let comment: String?
    
    enum CodingKeys: String, CodingKey {
        case submissionPhotos
        case comment
    }
}

struct ReviewAssignmentRequest: Codable {
    let parentFeedback: String?
}

// MARK: - Response Models

struct AssignmentListResponse: Codable {
    let assignments: [Assignment]
}

struct AssignmentStatistics: Codable {
    let total: Int
    let completed: Int
    let pending: Int
    let submitted: Int
    let totalPointsEarned: Int
}
