//
//  AssignmentService.swift
//  Cleveroo
//
//  Created by GitHub Copilot on 24/11/2025.
//

import Foundation
import Combine

class AssignmentService: ObservableObject {
    static let shared = AssignmentService()
    
    private let baseURL = APIConfig.baseURL
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Parent Functions
    
    /// Créer un assignment (Parent)
    func createAssignment(request: CreateAssignmentRequest, token: String) -> AnyPublisher<Assignment, Error> {
        let urlString = "\(baseURL)/assignments"
        print("🌐 AssignmentService: Creating assignment at \(urlString)")
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            urlRequest.httpBody = try encoder.encode(request)
            
            print("📤 AssignmentService: Request body: \(String(data: urlRequest.httpBody!, encoding: .utf8) ?? "nil")")
            
        } catch {
            print("❌ AssignmentService: Failed to encode request: \(error)")
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    print("📥 AssignmentService: Response status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode >= 400 {
                        if let responseString = String(data: data, encoding: .utf8) {
                            print("📥 AssignmentService: Error response: \(responseString)")
                        }
                        throw APIError.httpError(httpResponse.statusCode)
                    }
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📥 AssignmentService: Response body: \(responseString)")
                }
                
                return data
            }
            .decode(type: Assignment.self, decoder: {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return decoder
            }())
            .catch { error in
                print("❌ AssignmentService: Error: \(error)")
                return Fail<Assignment, Error>(error: error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Récupérer tous les assignments créés par le parent
    func getMyAssignments(token: String) -> AnyPublisher<[Assignment], Error> {
        let urlString = "\(baseURL)/assignments/parent/my"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    print("📥 AssignmentService: Get my assignments status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode >= 400 {
                        throw APIError.httpError(httpResponse.statusCode)
                    }
                }
                
                // Debug: Afficher la réponse JSON brute pour les assignments parent
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 AssignmentService: Raw JSON response for parent assignments:")
                    print(jsonString)
                } else {
                    print("❌ AssignmentService: Could not convert response data to string")
                }
                
                return data
            }
            .decode(type: [Assignment].self, decoder: {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return decoder
            }())
            .catch { error in
                print("❌ AssignmentService: Decode error for parent assignments: \(error)")
                if let decodingError = error as? DecodingError {
                    print("❌ AssignmentService: Detailed decoding error: \(decodingError)")
                }
                return Fail<[Assignment], Error>(error: error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Modifier un assignment (Parent)
    func updateAssignment(assignmentId: String, request: UpdateAssignmentRequest, token: String) -> AnyPublisher<Assignment, Error> {
        let urlString = "\(baseURL)/assignments/\(assignmentId)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            urlRequest.httpBody = try encoder.encode(request)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 400 {
                        throw APIError.httpError(httpResponse.statusCode)
                    }
                }
                return data
            }
            .decode(type: Assignment.self, decoder: {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return decoder
            }())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Supprimer un assignment (Parent)
    func deleteAssignment(assignmentId: String, token: String) -> AnyPublisher<Void, Error> {
        let urlString = "\(baseURL)/assignments/\(assignmentId)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { _, response in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 400 {
                        throw APIError.httpError(httpResponse.statusCode)
                    }
                }
                return ()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Approuver une soumission (Parent)
    func approveSubmission(assignmentId: String, feedback: String?, token: String) -> AnyPublisher<Assignment, Error> {
        let urlString = "\(baseURL)/assignments/\(assignmentId)/approve"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let request = ReviewAssignmentRequest(parentFeedback: feedback)
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 400 {
                        throw APIError.httpError(httpResponse.statusCode)
                    }
                }
                return data
            }
            .decode(type: Assignment.self, decoder: {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return decoder
            }())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Rejeter une soumission (Parent)
    func rejectSubmission(assignmentId: String, feedback: String?, token: String) -> AnyPublisher<Assignment, Error> {
        let urlString = "\(baseURL)/assignments/\(assignmentId)/reject"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let request = ReviewAssignmentRequest(parentFeedback: feedback)
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 400 {
                        throw APIError.httpError(httpResponse.statusCode)
                    }
                }
                return data
            }
            .decode(type: Assignment.self, decoder: {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return decoder
            }())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Child Functions
    
    /// Récupérer les assignments de l'enfant
    func getChildAssignments(token: String) -> AnyPublisher<[Assignment], Error> {
        let urlString = "\(baseURL)/assignments/child/my"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    print("📥 AssignmentService: Get child assignments status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode >= 400 {
                        throw APIError.httpError(httpResponse.statusCode)
                    }
                }
                
                // Debug: Afficher la réponse JSON brute
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 AssignmentService: Raw JSON response for child assignments:")
                    print(jsonString)
                } else {
                    print("❌ AssignmentService: Could not convert response data to string")
                }
                
                return data
            }
            .decode(type: [Assignment].self, decoder: {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return decoder
            }())
            .catch { error in
                print("❌ AssignmentService: Decode error for child assignments: \(error)")
                if let decodingError = error as? DecodingError {
                    print("❌ AssignmentService: Detailed decoding error: \(decodingError)")
                }
                return Fail<[Assignment], Error>(error: error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Marquer un assignment comme en cours (Enfant)
    func startAssignment(assignmentId: String, token: String) -> AnyPublisher<Assignment, Error> {
        let urlString = "\(baseURL)/assignments/\(assignmentId)/start"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 400 {
                        throw APIError.httpError(httpResponse.statusCode)
                    }
                }
                return data
            }
            .decode(type: Assignment.self, decoder: {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return decoder
            }())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Soumettre un assignment avec photos Base64 (Enfant)
    func submitAssignment(assignmentId: String, request: SubmitAssignmentRequest, token: String) -> AnyPublisher<Assignment, Error> {
        let urlString = "\(baseURL)/assignments/\(assignmentId)/submit-base64"
        print("🌐 AssignmentService: Submitting assignment at \(urlString)")
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
            print("📤 AssignmentService: Submitting \(request.photos.count) photos")
            
        } catch {
            print("❌ AssignmentService: Failed to encode submission: \(error)")
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    print("📥 AssignmentService: Submission status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode >= 400 {
                        if let responseString = String(data: data, encoding: .utf8) {
                            print("📥 AssignmentService: Error response: \(responseString)")
                        }
                        throw APIError.httpError(httpResponse.statusCode)
                    }
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📥 AssignmentService: Submission response: \(responseString)")
                }
                
                return data
            }
            .decode(type: Assignment.self, decoder: {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return decoder
            }())
            .catch { error in
                print("❌ AssignmentService: Submission error: \(error)")
                return Fail<Assignment, Error>(error: error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Common Functions
    
    /// Récupérer un assignment par ID
    func getAssignmentById(assignmentId: String, token: String) -> AnyPublisher<Assignment, Error> {
        let urlString = "\(baseURL)/assignments/\(assignmentId)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 400 {
                        throw APIError.httpError(httpResponse.statusCode)
                    }
                }
                return data
            }
            .decode(type: Assignment.self, decoder: {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return decoder
            }())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Récupérer les statistiques d'un enfant
    func getChildStatistics(childId: String, token: String) -> AnyPublisher<AssignmentStatistics, Error> {
        let urlString = "\(baseURL)/assignments/child/\(childId)/statistics"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 400 {
                        throw APIError.httpError(httpResponse.statusCode)
                    }
                }
                return data
            }
            .decode(type: AssignmentStatistics.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
