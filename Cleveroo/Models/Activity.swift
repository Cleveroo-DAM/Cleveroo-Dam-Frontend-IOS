//
//  Activity.swift
//  Cleveroo
//
//  Model for activity data from backend
//

import Foundation

struct Activity: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let type: String // "external_game", "quiz", etc.
    let domain: String // "logic", "math", etc.
    let externalUrl: String?
    let minAge: Int?
    let maxAge: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, description, type, domain, externalUrl, minAge, maxAge
    }
}
