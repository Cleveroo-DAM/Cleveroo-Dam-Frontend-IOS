//
//  MemoryGameService.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 14/11/2025.
//

import Foundation

class MemoryGameService {
    static let shared = MemoryGameService()
    private let baseURL = APIConfig.memoryGameBaseURL
    
    private init() {}
    
    // MARK: - Get Activities
    func getActivities() async throws -> [MemoryActivity] {
        guard let url = URL(string: "\(baseURL)/activities") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([MemoryActivity].self, from: data)
    }
    
    // MARK: - Start Game Session
    func startGame(activityId: String, userId: String) async throws -> MemoryGameSession {
        guard let url = URL(string: "\(baseURL)/sessions/start") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "activityId": activityId,
            "userId": userId
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(MemoryGameSession.self, from: data)
    }
    
    // MARK: - Record Move
    func recordMove(sessionId: String, move: CardMove) async throws {
        guard let url = URL(string: "\(baseURL)/sessions/\(sessionId)/record-move") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let formatter = ISO8601DateFormatter()
        let body: [String: Any] = [
            "cardId": move.cardId,
            "position": move.position,
            "matched": move.matched,
            "timestamp": formatter.string(from: move.timestamp)
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError
        }
    }
    
    // MARK: - Complete Game
    func completeGame(sessionId: String, results: GameResults) async throws -> MemoryGameSession {
        guard let url = URL(string: "\(baseURL)/sessions/\(sessionId)/complete") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "score": results.score,
            "timeSpent": results.timeSpent,
            "pairsFound": results.pairsFound,
            "totalMoves": results.totalMoves,
            "failedAttempts": results.failedAttempts,
            "perfectPairs": results.perfectPairs
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(MemoryGameSession.self, from: data)
    }
    
    // MARK: - Get Game History
    func getGameHistory(userId: String) async throws -> [MemoryGameSession] {
        let urlString = "\(baseURL)/sessions/user/\(userId)"
        print("🌐 === GET GAME HISTORY ===")
        print("🌐 URL: \(urlString)")
        print("👤 User ID: \(userId)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "jwt") {
            print("🔑 Token exists (first 30 chars): \(token.prefix(30))...")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("⚠️ WARNING: No JWT token found!")
        }
        
        print("📤 Sending HTTP GET request...")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                throw NetworkError.serverError
            }
            
            print("📥 Response Status Code: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response Body: \(responseString)")
            } else {
                print("📥 Response Body: (unable to decode as string)")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ Server returned error status: \(httpResponse.statusCode)")
                throw NetworkError.serverError
            }
            
            print("✅ Server responded with success status")
            print("🔄 Attempting to decode JSON...")
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let sessions = try decoder.decode([MemoryGameSession].self, from: data)
            print("✅ Successfully decoded \(sessions.count) game sessions")
            
            if sessions.isEmpty {
                print("⚠️ WARNING: API returned 0 sessions for user \(userId)")
                print("   This could mean:")
                print("   1. User has not played any games yet")
                print("   2. Backend endpoint is not returning data correctly")
                print("   3. User ID mismatch between frontend and backend")
            } else {
                print("📊 Sessions summary:")
                for (index, session) in sessions.enumerated() {
                    print("   [\(index + 1)] ID: \(session.id), Score: \(session.score), Status: \(session.status)")
                }
            }
            
            print("🌐 === END GET GAME HISTORY ===")
            return sessions
            
        } catch let decodingError as DecodingError {
            print("❌ Decoding Error: \(decodingError)")
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("   Key not found: \(key.stringValue)")
                print("   Context: \(context.debugDescription)")
            case .typeMismatch(let type, let context):
                print("   Type mismatch: expected \(type)")
                print("   Context: \(context.debugDescription)")
            case .valueNotFound(let type, let context):
                print("   Value not found: \(type)")
                print("   Context: \(context.debugDescription)")
            case .dataCorrupted(let context):
                print("   Data corrupted: \(context.debugDescription)")
            @unknown default:
                print("   Unknown decoding error")
            }
            throw NetworkError.decodingError
            
        } catch {
            print("❌ Network Error: \(error.localizedDescription)")
            print("❌ Full error: \(error)")
            throw error
        }
    }
}

// MARK: - Supporting Types
struct GameResults {
    let score: Int
    let timeSpent: Int
    let pairsFound: Int
    let totalMoves: Int
    let failedAttempts: Int
    let perfectPairs: Int
}

enum NetworkError: LocalizedError {
    case invalidURL
    case serverError
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .serverError: return "Server error"
        case .decodingError: return "Failed to decode response"
        }
    }
}
