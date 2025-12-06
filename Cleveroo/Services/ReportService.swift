//
//  ReportService.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/12/2025.
//

import Foundation
import Combine

class ReportService {
    static let shared = ReportService()
    private let baseURL = "\(APIConfig.baseURL)/reports"
    
    private init() {}
    
    // MARK: - Generate Report
    func generateReport(childId: String, period: String, token: String) -> AnyPublisher<Report, Error> {
        guard let url = URL(string: "\(baseURL)/generate/\(childId)?period=\(period)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        APIConfig.log("🔄 Generating \(period) report for child \(childId)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                APIConfig.log("📥 Report generation response: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    if let errorMessage = String(data: data, encoding: .utf8) {
                        APIConfig.log("❌ Report generation error: \(errorMessage)")
                    }
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: Report.self, decoder: self.createDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get All Reports
    func getReports(token: String, childId: String? = nil) -> AnyPublisher<[Report], Error> {
        var urlString = baseURL
        if let childId = childId {
            urlString += "?childId=\(childId)"
        }
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        APIConfig.log("🔄 Fetching reports\(childId != nil ? " for child \(childId!)" : "")")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                APIConfig.log("📥 Reports fetch response: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    if let errorMessage = String(data: data, encoding: .utf8) {
                        APIConfig.log("❌ Reports fetch error: \(errorMessage)")
                    }
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: [Report].self, decoder: self.createDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get Report by ID
    func getReport(reportId: String, token: String) -> AnyPublisher<Report, Error> {
        guard let url = URL(string: "\(baseURL)/\(reportId)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        APIConfig.log("🔄 Fetching report \(reportId)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                APIConfig.log("📥 Report fetch response: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    if let errorMessage = String(data: data, encoding: .utf8) {
                        APIConfig.log("❌ Report fetch error: \(errorMessage)")
                    }
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: Report.self, decoder: self.createDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    private func createDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
