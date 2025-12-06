//
//  ParentalControlService.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 30/11/2025.
//

import Foundation

class ParentalControlService {
    static let shared = ParentalControlService()
    
    private init() {}
    
    // MARK: - Parent Actions
    
    /// Bloquer ou débloquer un enfant
    func setChildBlockStatus(childId: String, isBlocked: Bool, blockReason: String? = nil) async throws {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let url = URL(string: "\(APIConfig.baseURL)/parent/parental-control/\(childId)/block")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "isBlocked": isBlocked,
            "blockReason": blockReason ?? ""
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to update block status"])
        }
    }
    
    /// Définir les plages horaires autorisées
    func setChildTimeSlots(childId: String, allowedTimeSlots: [String]) async throws {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let url = URL(string: "\(APIConfig.baseURL)/parent/parental-control/\(childId)/time-slots")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["allowedTimeSlots": allowedTimeSlots]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to update time slots"])
        }
    }
    
    /// Définir la limite de temps d'écran quotidien (en minutes)
    func setChildScreenTimeLimit(childId: String, dailyScreenTimeLimit: Int) async throws {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let url = URL(string: "\(APIConfig.baseURL)/parent/parental-control/\(childId)/screen-time-limit")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["dailyScreenTimeLimit": dailyScreenTimeLimit]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to update screen time limit"])
        }
    }
    
    /// Obtenir les paramètres de contrôle parental pour un enfant
    func getChildParentalControl(childId: String) async throws -> ParentalControl {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let url = URL(string: "\(APIConfig.baseURL)/parent/parental-control/\(childId)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let control = try JSONDecoder().decode(ParentalControl.self, from: data)
        return control
    }
    
    /// Obtenir l'historique des actions de contrôle parental pour un enfant
    func getChildHistory(childId: String, limit: Int = 20) async throws -> [ParentalControlHistory] {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let url = URL(string: "\(APIConfig.baseURL)/parent/parental-control/\(childId)/history?limit=\(limit)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let history = try JSONDecoder().decode([ParentalControlHistory].self, from: data)
        return history
    }
    
    /// Obtenir les demandes de déblocage
    func getUnblockRequests(status: String? = nil) async throws -> [UnblockRequest] {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        var urlString = "\(APIConfig.baseURL)/parent/unblock-requests"
        if let status = status {
            urlString += "?status=\(status)"
        }
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let requests = try JSONDecoder().decode([UnblockRequest].self, from: data)
        return requests
    }
    
    /// Approuver ou rejeter une demande de déblocage
    func respondToUnblockRequest(requestId: String, approve: Bool, parentResponse: String? = nil) async throws {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let url = URL(string: "\(APIConfig.baseURL)/parent/unblock-requests/\(requestId)/respond")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = ["approve": approve]
        if let response = parentResponse {
            body["parentResponse"] = response
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to respond to request"])
        }
    }
    
    /// Obtenir le temps d'écran utilisé aujourd'hui par un enfant
    func getTodayScreenTime(childId: String) async throws -> ScreenTimeData {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let url = URL(string: "\(APIConfig.baseURL)/parent/screen-time/\(childId)/today")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let screenTime = try JSONDecoder().decode(ScreenTimeData.self, from: data)
        return screenTime
    }
    
    /// Obtenir l'historique du temps d'écran d'un enfant
    func getScreenTimeHistory(childId: String, days: Int = 7) async throws -> [ScreenTimeHistoryEntry] {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let url = URL(string: "\(APIConfig.baseURL)/parent/screen-time/\(childId)/history?days=\(days)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let history = try JSONDecoder().decode([ScreenTimeHistoryEntry].self, from: data)
        return history
    }
    
    // MARK: - Child Actions
    
    /// Enfant: demander le déblocage au parent
    func createUnblockRequest(reason: String) async throws {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let url = URL(string: "\(APIConfig.baseURL)/child/unblock-request")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["reason": reason]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "API", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create unblock request"])
        }
    }
    
    /// Enfant: vérifier le statut de sa demande
    func getMyUnblockRequestStatus() async throws -> [UnblockRequest] {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let url = URL(string: "\(APIConfig.baseURL)/child/unblock-request/status")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let requests = try JSONDecoder().decode([UnblockRequest].self, from: data)
        return requests
    }
    
    /// Enfant: vérifier si son accès est restreint
    func getRestrictionStatus() async throws -> RestrictionStatus {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let url = URL(string: "\(APIConfig.baseURL)/child/restriction-status")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let status = try JSONDecoder().decode(RestrictionStatus.self, from: data)
        return status
    }
    
    /// Enfant: obtenir son temps d'écran aujourd'hui
    func getMyScreenTimeToday() async throws -> ScreenTimeData {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let url = URL(string: "\(APIConfig.baseURL)/auth/screen-time/today")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let screenTime = try JSONDecoder().decode(ScreenTimeData.self, from: data)
        return screenTime
    }
    
    /// Enfant: obtenir l'historique de son temps d'écran
    func getMyScreenTimeHistory() async throws -> [ScreenTimeHistoryEntry] {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let url = URL(string: "\(APIConfig.baseURL)/auth/screen-time/history")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let history = try JSONDecoder().decode([ScreenTimeHistoryEntry].self, from: data)
        return history
    }
    
    /// Enfant: obtenir ses propres paramètres de contrôle parental
    func getMyParentalControl() async throws -> ParentalControl {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let url = URL(string: "\(APIConfig.baseURL)/child/parental-control")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Debug: Print raw response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📋 Parental Control Response: \(jsonString)")
        }
        
        let control = try JSONDecoder().decode(ParentalControl.self, from: data)
        print("✅ Parental Control decoded: isBlocked=\(control.isBlocked ?? false), timeSlots=\(control.allowedTimeSlots?.count ?? 0)")
        return control
    }
}
