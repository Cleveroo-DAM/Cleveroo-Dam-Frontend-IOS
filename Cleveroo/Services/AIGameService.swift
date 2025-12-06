//
//  AIGameService.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 24/11/2025.
//

import Foundation
import Combine

// MARK: - Error Types
enum APIError: LocalizedError {
    case serverError(String)
    case httpError(Int)
    case networkError
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .serverError(let message):
            return message
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .networkError:
            return "Network error occurred"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}

struct APIErrorResponse: Codable {
    let statusCode: Int?
    let message: String
    let error: String?
}

class AIGameService: ObservableObject {
    static let shared = AIGameService()
    
    private let baseURL = APIConfig.baseURL
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Parent Functions
    
    /// Génère un nouveau jeu AI (Parent seulement)
    func generateGame(request: GenerateGameRequest, token: String) -> AnyPublisher<GeneratedGame, Error> {
        let urlString = "\(baseURL)/ai-games/generate"
        print("🌐 AIGameService: Attempting to generate game at \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ AIGameService: Invalid URL: \(urlString)")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            urlRequest.httpBody = try encoder.encode(request)
            
            // Log request details
            print("📤 AIGameService: Request body: \(String(data: urlRequest.httpBody!, encoding: .utf8) ?? "nil")")
            print("🔑 AIGameService: Token length: \(token.count) characters")
            print("🔑 AIGameService: Token starts with: \(token.prefix(20))...")
            
        } catch {
            print("❌ AIGameService: Failed to encode request: \(error)")
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                // Log response details
                if let httpResponse = response as? HTTPURLResponse {
                    print("📥 AIGameService: Response status: \(httpResponse.statusCode)")
                    
                    // Check for HTTP errors
                    if httpResponse.statusCode >= 400 {
                        if let responseString = String(data: data, encoding: .utf8) {
                            print("📥 AIGameService: Error response body: \(responseString)")
                        }
                        
                        // Try to decode error response
                        if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                            throw APIError.serverError(errorResponse.message)
                        } else {
                            throw APIError.httpError(httpResponse.statusCode)
                        }
                    }
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📥 AIGameService: Response body: \(responseString)")
                }
                
                // Check for empty data
                guard !data.isEmpty else {
                    print("❌ AIGameService: Empty response data")
                    throw URLError(.cannotParseResponse)
                }
                
                return data
            }
            .decode(type: GeneratedGame.self, decoder: JSONDecoder())
            .catch { error in
                print("❌ AIGameService: Error: \(error)")
                return Fail<GeneratedGame, Error>(error: error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Récupère les progrès d'un enfant (Parent seulement)
    func getChildProgress(childId: String, token: String) -> AnyPublisher<ChildProgressResponse, Error> {
        guard let url = URL(string: "\(baseURL)/ai-games/parent/child/\(childId)/progress") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: ChildProgressResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Récupère le rapport d'une session (Parent seulement)
    func getSessionReport(sessionId: String, token: String) -> AnyPublisher<PersonalityResult, Error> {
        guard let url = URL(string: "\(baseURL)/ai-games/session/\(sessionId)/report") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: [String: PersonalityResult].self, decoder: JSONDecoder())
            .map { $0["personalityResult"] ?? PersonalityResult(scores: nil, metrics: nil, report: nil) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Child Functions
    
    /// Récupère tous les jeux disponibles pour un enfant
    func getMyGames(token: String) -> AnyPublisher<GamesForChildResponse, Error> {
        guard let url = URL(string: "\(baseURL)/ai-games/my-games") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: GamesForChildResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Récupère un jeu spécifique
    func getGame(gameId: String, token: String) -> AnyPublisher<GeneratedGame, Error> {
        guard let url = URL(string: "\(baseURL)/ai-games/\(gameId)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: GeneratedGame.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Démarre une session de jeu
    func startSession(gameId: String, token: String) -> AnyPublisher<StartSessionResponse, Error> {
        guard let url = URL(string: "\(baseURL)/ai-games/\(gameId)/start-session") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: StartSessionResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Récupère une session existante
    func getSession(sessionId: String, token: String) -> AnyPublisher<StartSessionResponse, Error> {
        guard let url = URL(string: "\(baseURL)/ai-games/session/\(sessionId)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: StartSessionResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Envoie des événements de jeu
    func pushEvents(sessionId: String, events: [GameEvent], token: String? = nil) -> AnyPublisher<PushEventsResponse, Error> {
        guard let url = URL(string: "\(baseURL)/ai-games/session/\(sessionId)/events") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let request = PushEventsRequest(events: events)
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: PushEventsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Termine une session de jeu
    func completeSession(sessionId: String, token: String) -> AnyPublisher<PersonalityResult, Error> {
        guard let url = URL(string: "\(baseURL)/ai-games/session/\(sessionId)/complete") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: [String: PersonalityResult].self, decoder: JSONDecoder())
            .compactMap { response in
                // Le backend retourne { "metrics": ..., "personality": ... }
                return response["personality"]
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Récupère les statistiques d'un jeu (combien de fois joué, meilleur score, etc.)
    func getGameStats(gameId: String, token: String) -> AnyPublisher<GameStats, Error> {
        guard let url = URL(string: "\(baseURL)/ai-games/\(gameId)/stats") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: GameStats.self, decoder: JSONDecoder())
            .catch { error in
                // Si l'endpoint n'existe pas, retourner des stats par défaut
                print("⚠️ Unable to fetch game stats: \(error)")
                return Just(GameStats(id: gameId, gameId: gameId, childId: "", timesPlayed: 0, bestScore: nil, lastPlayedAt: nil, sessions: nil))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Helper Extensions
extension JSONDecoder {
    static let aiGameDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()
}

extension JSONEncoder {
    static let aiGameEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        encoder.dateEncodingStrategy = .formatted(formatter)
        return encoder
    }()
}
