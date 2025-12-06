//
//  GamificationService.swift
//  Cleveroo
//
//  Created by GitHub Copilot on 30/11/2025.
//

import Foundation
import Combine

class GamificationService {
    static let shared = GamificationService()
    private let baseURL = APIConfig.baseURL
    
    // MARK: - Get My Profile (Child)
    func getMyProfile(token: String) -> AnyPublisher<GamificationProfile, Error> {
        guard let url = URL(string: "\(baseURL)/gamification/profile") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("🎮 Gamification: Get my profile")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                print("📥 Gamification Profile Status: \(httpResponse.statusCode)")
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 Gamification Profile Response: \(jsonString)")
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: GamificationProfile.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get Child Profile (Parent)
    func getChildProfile(childId: String, token: String) -> AnyPublisher<GamificationProfile, Error> {
        guard let url = URL(string: "\(baseURL)/gamification/child/\(childId)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("🎮 Gamification: Get child profile for \(childId)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                print("📥 Child Profile Status: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: GamificationProfile.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get Global Leaderboard
    func getLeaderboard(limit: Int = 10, token: String) -> AnyPublisher<[GamificationLeaderboardEntry], Error> {
        guard let url = URL(string: "\(baseURL)/gamification/leaderboard?limit=\(limit)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("🏆 Gamification: Get leaderboard (limit: \(limit))")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                print("📥 Leaderboard Status: \(httpResponse.statusCode)")
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 Leaderboard Response: \(jsonString)")
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: [GamificationLeaderboardEntry].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get Parent's Children Leaderboard
    func getMyChildrenLeaderboard(limit: Int = 10, token: String) -> AnyPublisher<[GamificationLeaderboardEntry], Error> {
        guard let url = URL(string: "\(baseURL)/gamification/leaderboard/my-children?limit=\(limit)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("🏆 Gamification: Get my children leaderboard (limit: \(limit))")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                print("📥 My Children Leaderboard Status: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: [GamificationLeaderboardEntry].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get All Badges with Status
    func getMyBadges(token: String) -> AnyPublisher<[BadgeWithStatus], Error> {
        guard let url = URL(string: "\(baseURL)/gamification/badges") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("🏅 Gamification: Get my badges")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                print("📥 Badges Status: \(httpResponse.statusCode)")
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 Badges Response: \(jsonString)")
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: [BadgeWithStatus].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get Child Badges (Parent)
    func getChildBadges(childId: String, token: String) -> AnyPublisher<[BadgeWithStatus], Error> {
        guard let url = URL(string: "\(baseURL)/gamification/badges/\(childId)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("🏅 Gamification: Get badges for child \(childId)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                print("📥 Child Badges Status: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: [BadgeWithStatus].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
