//
//  AIGameAssignmentService.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 24/11/2025.
//

import Foundation
import Combine

class AIGameAssignmentService: ObservableObject {
    static let shared = AIGameAssignmentService()
    
    private let baseURL = APIConfig.apiBaseURL
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Assignment Models
    struct AIGameAssignment: Codable, Identifiable {
        let id: String
        let childId: String
        let gameId: String
        let parentId: String
        let status: AssignmentStatus
        let dueDate: Date?
        let priority: Priority
        let instructions: String?
        let estimatedDuration: Int? // en minutes
        let createdAt: Date
        let completedAt: Date?
        let score: Double?
        let feedback: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case childId, gameId, parentId, status, dueDate, priority
            case instructions, estimatedDuration, createdAt, completedAt, score, feedback
        }
    }
    
    enum AssignmentStatus: String, Codable, CaseIterable {
        case assigned = "assigned"
        case inProgress = "in_progress" 
        case completed = "completed"
        case overdue = "overdue"
        case cancelled = "cancelled"
        
        var displayName: String {
            switch self {
            case .assigned: return "Assigné"
            case .inProgress: return "En cours"
            case .completed: return "Terminé"
            case .overdue: return "En retard"
            case .cancelled: return "Annulé"
            }
        }
        
        var color: Color {
            switch self {
            case .assigned: return .blue
            case .inProgress: return .orange
            case .completed: return .green
            case .overdue: return .red
            case .cancelled: return .gray
            }
        }
    }
    
    enum Priority: String, Codable, CaseIterable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case urgent = "urgent"
        
        var displayName: String {
            switch self {
            case .low: return "Faible"
            case .medium: return "Moyen"
            case .high: return "Élevé" 
            case .urgent: return "Urgent"
            }
        }
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .yellow
            case .high: return .orange
            case .urgent: return .red
            }
        }
    }
    
    struct AssignGameRequest: Codable {
        let childId: String
        let gameId: String
        let dueDate: Date?
        let priority: Priority
        let instructions: String?
    }
    
    // MARK: - API Methods
    
    /// Parent assigne un jeu IA à un enfant
    func assignGameToChild(request: AssignGameRequest, token: String) -> AnyPublisher<AIGameAssignment, Error> {
        guard let url = URL(string: "\(baseURL)/ai-games/assign") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            encoder.dateEncodingStrategy = .formatted(formatter)
            urlRequest.httpBody = try encoder.encode(request)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: AIGameAssignment.self, decoder: createDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Récupère les assignments d'un enfant
    func getChildAssignments(childId: String, token: String) -> AnyPublisher<[AIGameAssignment], Error> {
        guard let url = URL(string: "\(baseURL)/ai-games/child/\(childId)/assignments") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: [AIGameAssignment].self, decoder: createDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Parent récupère tous les assignments qu'il a créés
    func getParentAssignments(token: String) -> AnyPublisher<[AIGameAssignment], Error> {
        guard let url = URL(string: "\(baseURL)/ai-games/parent/assignments") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: [AIGameAssignment].self, decoder: createDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Met à jour le statut d'un assignment
    func updateAssignmentStatus(assignmentId: String, status: AssignmentStatus, token: String) -> AnyPublisher<AIGameAssignment, Error> {
        guard let url = URL(string: "\(baseURL)/ai-games/assignments/\(assignmentId)/status") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["status": status.rawValue]
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: AIGameAssignment.self, decoder: createDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Annule un assignment (parent seulement)
    func cancelAssignment(assignmentId: String, token: String) -> AnyPublisher<Bool, Error> {
        return updateAssignmentStatus(assignmentId: assignmentId, status: .cancelled, token: token)
            .map { _ in true }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper
    private func createDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }
}

import SwiftUI