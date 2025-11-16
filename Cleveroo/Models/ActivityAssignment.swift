//
//  ActivityAssignment.swift
//  Cleveroo
//
//  Model for activity assignment with nested details
//

import Foundation

struct ActivityAssignment: Codable, Identifiable {
    let id: String
    let childId: String
    let activityId: ActivityDetails
    let status: String // "assigned", "in_progress", "completed"
    let dueDate: String?
    let score: Int?
    let notes: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case childId, activityId, status, dueDate, score, notes, createdAt, updatedAt
    }
}

struct ActivityDetails: Codable {
    let id: String
    let title: String
    let description: String?
    let type: String
    let domain: String
    let externalUrl: String?
    let minAge: Int?
    let maxAge: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, description, type, domain, externalUrl, minAge, maxAge
    }
}
