//
//  AuthViewModel.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/11/2025.
//  Corrigé & optimisé le 10/11/2025
//
//
//  AuthViewModel.swift
//  Cleveroo
//

import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    
    // MARK: - User Role Enum
    enum UserRole {
        case child
        case parent
    }
    
    // MARK: - Published Properties
    @Published var identifier = ""       // email ou username
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var age = ""
    @Published var parentEmail = ""
    @Published var parentPhone = ""
    @Published var childUsername = ""
    @Published var childGender = "Boy"
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isLoggedIn = false
    @Published var isRegistered = false
    @Published var userProfile: [String: Any] = [:]
    @Published var isParent = false
    
    // MARK: - API Base URL
    private let baseURL = "http://localhost:3000/auth"
    
    // MARK: - LOGIN
    func login(identifier: String, rememberMe: Bool = false) {
        guard !identifier.isEmpty, !password.isEmpty else {
            setError("Please enter your credentials.")
            return
        }

        isLoading = true
        let isEmail = identifier.contains("@")
        let endpoint = isEmail ? "\(baseURL)/login/parent" : "\(baseURL)/login/child"
        let body: [String: Any] = isEmail
            ? ["email": identifier, "password": password]
            : ["username": identifier, "password": password]

        sendRequest(urlString: endpoint, body: body) { [weak self] success, json, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let token = json?["access_token"] as? String {
                    UserDefaults.standard.set(token, forKey: "jwt")
                    self?.isParent = isEmail
                    self?.isLoggedIn = true
                    if rememberMe { self?.saveIdentifier(identifier) }
                    self?.fetchProfile()
                } else {
                    self?.errorMessage = error ?? "Login failed."
                }
            }
        }
    }
    
    // MARK: - REGISTER
    func register() {
        guard !childUsername.isEmpty else { setError("Please enter a child username."); return }
        guard let ageInt = Int(age), ageInt > 0 else { setError("Please enter a valid age."); return }
        guard !parentEmail.isEmpty else { setError("Please enter a parent email."); return }
        guard !parentPhone.isEmpty else { setError("Please enter a parent phone."); return }
        guard !password.isEmpty, password == confirmPassword else { setError("Passwords do not match."); return }

        isLoading = true
        let body: [String: Any] = [
            "username": childUsername,
            "password": password,
            "confirmPassword": confirmPassword,
            "age": ageInt,
            "email": parentEmail,
            "phone": parentPhone
        ]

        sendRequest(urlString: "\(baseURL)/register", body: body) { [weak self] success, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success {
                    self?.isRegistered = true
                } else {
                    self?.errorMessage = error ?? "Registration failed."
                }
            }
        }
    }
    
    // MARK: - FETCH PROFILE
    func fetchProfile() {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            print("No token found.")
            return
        }

        let parentEndpoint = "\(baseURL)/profile/parent"
        let childEndpoint = "\(baseURL)/profile/child"
        
        sendRequest(urlString: parentEndpoint, method: "GET", token: token) { [weak self] success, json, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if success, let json = json {
                    self.isParent = true
                    self.userProfile = json
                    self.parentEmail = json["email"] as? String ?? ""
                    self.parentPhone = json["phone"] as? String ?? ""
                    
                    if let child = json["child"] as? [String: Any] {
                        self.childUsername = child["username"] as? String ?? ""
                        if let age = child["age"] as? Int { self.age = "\(age)" }
                        self.childGender = child["gender"] as? String ?? "Boy"
                    }
                    print("Parent profile fetched")
                } else {
                    self.sendRequest(urlString: childEndpoint, method: "GET", token: token) { successChild, jsonChild, _ in
                        DispatchQueue.main.async {
                            if successChild, let jsonChild = jsonChild {
                                self.isParent = false
                                self.userProfile = jsonChild
                                self.childUsername = jsonChild["username"] as? String ?? ""
                                self.childGender = jsonChild["gender"] as? String ?? "Boy"
                                if let age = jsonChild["age"] as? Int { self.age = "\(age)" }
                                print("Child profile fetched")
                            } else {
                                self.errorMessage = error ?? "Failed to fetch profile."
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - LOGOUT
    func logout() {
        identifier = ""; password = ""; confirmPassword = ""
        age = ""; parentEmail = ""; parentPhone = ""
        childUsername = ""; childGender = "Boy"
        userProfile = [:]; isLoggedIn = false; isParent = false
        UserDefaults.standard.removeObject(forKey: "jwt")
    }
    
    // MARK: - UPDATE PROFILE
    func updateProfile(completion: @escaping (Bool, String?) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            completion(false, "No token found")
            return
        }
        
        let endpoint = isParent ? "\(baseURL)/profile/parent" : "\(baseURL)/profile/child"
        var body: [String: Any] = [:]
        
        if isParent {
            body["email"] = parentEmail
            body["phone"] = parentPhone
        } else {
            body["username"] = childUsername
            body["gender"] = childGender
            body["age"] = Int(age) ?? 0
        }
        
        sendRequest(urlString: endpoint, method: "PATCH", body: body, token: token) { success, _, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    // MARK: - FORGOT PASSWORD – Envoie email (pas de code retourné)
    func sendForgotPasswordCode(email: String, completion: @escaping (Bool, String?) -> Void) {
        let endpoint = "\(baseURL)/forgot-password"
        let body: [String: Any] = ["email": email]

        sendRequest(urlString: endpoint, body: body) { success, _, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    // MARK: - UPDATE PASSWORD – Connecté (ancien mot de passe requis)
    func updateParentPassword(
        oldPassword: String,
        newPassword: String,
        confirmPassword: String,
        completion: @escaping (Bool, String?) -> Void
    ) {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            completion(false, "No token found")
            return
        }
        
        let endpoint = "\(baseURL)/profile/parent/password"
        let body: [String: Any] = [
            "oldPassword": oldPassword,
            "newPassword": newPassword,
            "confirmPassword": confirmPassword
        ]
        
        sendRequest(urlString: endpoint, method: "PATCH", body: body, token: token) { success, _, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }

    // MARK: - HELPER: sendRequest
    private func sendRequest(
        urlString: String,
        method: String = "POST",
        body: [String: Any]? = nil,
        token: String? = nil,
        completion: @escaping (Bool, [String: Any]?, String?) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(false, nil, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, nil, "Network error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(false, nil, "Invalid response")
                return
            }
            
            let json = data.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }
            let message = json?["message"] as? String
            
            if (200...299).contains(httpResponse.statusCode) {
                completion(true, json, nil)
            } else {
                completion(false, nil, message ?? "Server error")
            }
        }.resume()
    }
    
    // MARK: - Helper: setError
    private func setError(_ message: String) {
        errorMessage = message
        isLoading = false
    }
    
    // MARK: - Remember Me
    func saveIdentifier(_ identifier: String) {
        UserDefaults.standard.set(identifier, forKey: "savedIdentifier")
    }
    
    func loadSavedIdentifier() -> String? {
        UserDefaults.standard.string(forKey: "savedIdentifier")
    }
}
