//
//  AuthModels.swift
//  Cleveroo
//
//  Data models for authentication and user management
//

import Foundation

// MARK: - Request Models

struct ParentRegisterRequest: Codable {
    let email: String
    let phone: String
    let password: String
    let confirmPassword: String
}

struct LoginParentRequest: Codable {
    let email: String
    let password: String
}

struct LoginChildRequest: Codable {
    let username: String
    let password: String
}

struct AddChildRequest: Codable {
    let username: String
    let age: Int
    let gender: String // "male" or "female"
}

// MARK: - Response Models

struct AuthResponse: Codable {
    let access_token: String
    let token_type: String
    let parent: ParentInfo?
    let child: ChildInfo?
}

struct ParentInfo: Codable {
    let id: String
    let email: String
    let phone: String
    let avatar: String?
}

struct ChildInfo: Codable {
    let id: String
    let username: String
    let age: Int
    let gender: String
    let avatar: String?
}

struct ChildResponse: Codable {
    let id: String
    let username: String
    let age: Int
    let gender: String
    let avatar: String?
}

// MARK: - Error Response

struct ErrorResponse: Codable {
    let message: String
    let statusCode: Int?
}
