//
//  ActivityViewModel.swift
//  Cleveroo
//
//  ViewModel for managing activities and assignments
//

import Foundation
import Combine

@MainActor
class ActivityViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var allActivities: [Activity] = []
    @Published var childAssignments: [ActivityAssignment] = []
    @Published var myAssignments: [ActivityAssignment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - API Base URL
    private let baseURL = "http://localhost:3000/activities"
    
    // MARK: - Fetch All Activities
    func fetchAllActivities() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: baseURL) else {
            setError("Invalid URL")
            return
        }
        
        print("🌐 Fetching all activities from: \(baseURL)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid response")
                    self.errorMessage = "Invalid response"
                    return
                }
                
                print("📥 Response Status: \(httpResponse.statusCode)")
                
                if (200...299).contains(httpResponse.statusCode) {
                    guard let data = data else {
                        print("❌ No data received")
                        self.errorMessage = "No data received"
                        return
                    }
                    
                    do {
                        let activities = try JSONDecoder().decode([Activity].self, from: data)
                        print("✅ Fetched \(activities.count) activities")
                        self.allActivities = activities
                    } catch {
                        print("❌ Decoding error: \(error)")
                        self.errorMessage = "Failed to parse activities"
                    }
                } else {
                    let message = self.parseErrorMessage(from: data)
                    print("❌ Request failed: \(message)")
                    self.errorMessage = message
                }
            }
        }.resume()
    }
    
    // MARK: - Assign Activity
    func assignActivity(childId: String, activityId: String, dueDate: String? = nil, completion: @escaping (Bool, String?) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            print("❌ No token found for assigning activity")
            completion(false, "Not authenticated. Please login first.")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let endpoint = "\(baseURL)/assign"
        guard let url = URL(string: endpoint) else {
            completion(false, "Invalid URL")
            return
        }
        
        var body: [String: Any] = [
            "childId": childId,
            "activityId": activityId
        ]
        if let dueDate = dueDate {
            body["dueDate"] = dueDate
        }
        
        print("🌐 Assigning activity: \(activityId) to child: \(childId)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    completion(false, "Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid response")
                    completion(false, "Invalid response")
                    return
                }
                
                print("📥 Response Status: \(httpResponse.statusCode)")
                
                if (200...299).contains(httpResponse.statusCode) {
                    print("✅ Activity assigned successfully")
                    completion(true, nil)
                } else {
                    let message = self.parseErrorMessage(from: data)
                    print("❌ Failed to assign activity: \(message)")
                    completion(false, message)
                }
            }
        }.resume()
    }
    
    // MARK: - Fetch Activities for Child
    func fetchActivitiesForChild(childId: String) {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            print("❌ No token found for fetching child activities")
            setError("Not authenticated. Please login first.")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let endpoint = "\(baseURL)/child/\(childId)"
        guard let url = URL(string: endpoint) else {
            setError("Invalid URL")
            return
        }
        
        print("🌐 Fetching activities for child: \(childId)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid response")
                    self.errorMessage = "Invalid response"
                    return
                }
                
                print("📥 Response Status: \(httpResponse.statusCode)")
                
                if (200...299).contains(httpResponse.statusCode) {
                    guard let data = data else {
                        print("❌ No data received")
                        self.errorMessage = "No data received"
                        return
                    }
                    
                    do {
                        let assignments = try JSONDecoder().decode([ActivityAssignment].self, from: data)
                        print("✅ Fetched \(assignments.count) assignments for child")
                        self.childAssignments = assignments
                    } catch {
                        print("❌ Decoding error: \(error)")
                        self.errorMessage = "Failed to parse assignments"
                    }
                } else {
                    let message = self.parseErrorMessage(from: data)
                    print("❌ Request failed: \(message)")
                    self.errorMessage = message
                }
            }
        }.resume()
    }
    
    // MARK: - Fetch My Activities (for child)
    func fetchMyActivities() {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            print("❌ No token found for fetching my activities")
            setError("Not authenticated. Please login first.")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let endpoint = "\(baseURL)/my"
        guard let url = URL(string: endpoint) else {
            setError("Invalid URL")
            return
        }
        
        print("🌐 Fetching my activities")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid response")
                    self.errorMessage = "Invalid response"
                    return
                }
                
                print("📥 Response Status: \(httpResponse.statusCode)")
                
                if (200...299).contains(httpResponse.statusCode) {
                    guard let data = data else {
                        print("❌ No data received")
                        self.errorMessage = "No data received"
                        return
                    }
                    
                    do {
                        let assignments = try JSONDecoder().decode([ActivityAssignment].self, from: data)
                        print("✅ Fetched \(assignments.count) my assignments")
                        self.myAssignments = assignments
                    } catch {
                        print("❌ Decoding error: \(error)")
                        self.errorMessage = "Failed to parse assignments"
                    }
                } else {
                    let message = self.parseErrorMessage(from: data)
                    print("❌ Request failed: \(message)")
                    self.errorMessage = message
                }
            }
        }.resume()
    }
    
    // MARK: - Complete Activity
    func completeActivity(assignmentId: String, score: Int? = nil, notes: String? = nil, completion: @escaping (Bool, String?) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            print("❌ No token found for completing activity")
            completion(false, "Not authenticated. Please login first.")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let endpoint = "\(baseURL)/assignments/\(assignmentId)/complete"
        guard let url = URL(string: endpoint) else {
            completion(false, "Invalid URL")
            return
        }
        
        var body: [String: Any] = [:]
        if let score = score {
            body["score"] = score
        }
        if let notes = notes, !notes.isEmpty {
            body["notes"] = notes
        }
        
        print("🌐 Completing activity assignment: \(assignmentId)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    completion(false, "Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid response")
                    completion(false, "Invalid response")
                    return
                }
                
                print("📥 Response Status: \(httpResponse.statusCode)")
                
                if (200...299).contains(httpResponse.statusCode) {
                    print("✅ Activity completed successfully")
                    completion(true, nil)
                } else {
                    let message = self.parseErrorMessage(from: data)
                    print("❌ Failed to complete activity: \(message)")
                    completion(false, message)
                }
            }
        }.resume()
    }
    
    // MARK: - Helper Methods
    private func setError(_ message: String) {
        errorMessage = message
        isLoading = false
    }
    
    private func parseErrorMessage(from data: Data?) -> String {
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let message = json["message"] as? String else {
            return "An unknown error occurred"
        }
        return message
    }
}
