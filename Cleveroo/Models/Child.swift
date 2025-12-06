//
//  Child.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/11/2025.
//

import Foundation

struct Child: Codable, Identifiable {
    var id: String?
    var username: String
    var age: Int
    var gender: String?
    var avatarURL: String?
    var qrCode: String?  // Base64 encoded QR code image
    var isRestricted: Bool? // Contrôle parental
    var parentId: String?
}
