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
    enum UserRole: Hashable, Equatable {
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
    @Published var currentChildId: String?
    @Published var childrenList: [[String: Any]] = []
    @Published var avatarURL: String?
    
    // MARK: - API Base URL
    private let baseURL = "http://localhost:3000/auth"
    private let parentBaseURL = "http://localhost:3000/parent"
    private let qrExchangeURL = "http://localhost:3000/qr/exchange"
    
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
                guard let self = self else { return }
                self.isLoading = false
                
                if success, let token = json?["access_token"] as? String {
                    print("✅ Login successful, token saved")
                    UserDefaults.standard.set(token, forKey: "jwt")
                    self.isParent = isEmail
                    self.isLoggedIn = true
                    
                    // Si Remember Me est coché, sauvegarder la session
                    if rememberMe {
                        print("💾 Saving session with Remember Me")
                        UserDefaults.standard.set(true, forKey: "rememberMe")
                        UserDefaults.standard.set(identifier, forKey: "savedIdentifier")
                        UserDefaults.standard.set(isEmail, forKey: "isParent")
                    }
                    self.saveIdentifier(identifier)
                    
                    // Appeler directement le bon endpoint selon le type
                    if isEmail {
                        print("📧 Fetching parent profile...")
                        self.fetchParentProfile()
                    } else {
                        print("👶 Fetching child profile...")
                        self.fetchChildProfile()
                    }
                } else {
                    print("❌ Login failed: \(error ?? "Unknown error")")
                    self.errorMessage = error ?? "Login failed."
                }
            }
        }
    }
    
    // MARK: - REGISTER (old - creates parent + child together)
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
    
    // MARK: - REGISTER PARENT ONLY (new backend logic)
    func registerParent(email: String, phone: String, password: String, confirmPassword: String, completion: @escaping (Bool, String?) -> Void) {
        guard !email.isEmpty else {
            completion(false, "Please enter an email.")
            return
        }
        guard !phone.isEmpty else {
            completion(false, "Please enter a phone number.")
            return
        }
        guard !password.isEmpty, password == confirmPassword else {
            completion(false, "Passwords do not match.")
            return
        }

        isLoading = true
        let body: [String: Any] = [
            "email": email,
            "phone": phone,
            "password": password,
            "confirmPassword": confirmPassword
        ]

        sendRequest(urlString: "\(baseURL)/register", body: body) { [weak self] success, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success {
                    print("✅ Parent registered successfully")
                    self?.isRegistered = true
                    completion(true, nil)
                } else {
                    print("❌ Parent registration failed: \(error ?? "Unknown error")")
                    completion(false, error ?? "Registration failed.")
                }
            }
        }
    }
    
    // MARK: - ADD CHILD (protected by JWT)
    func addChild(username: String, age: Int, gender: String, completion: @escaping (Bool, String?) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            print("❌ No token found for adding child")
            completion(false, "Not authenticated. Please login first.")
            return
        }
        
        guard !username.isEmpty else {
            completion(false, "Please enter a username.")
            return
        }
        
        guard age > 0 else {
            completion(false, "Please enter a valid age.")
            return
        }

        isLoading = true
        let body: [String: Any] = [
            "username": username,
            "age": age,
            "gender": gender
        ]

        let endpoint = "\(parentBaseURL)/children"
        
        sendRequest(urlString: endpoint, method: "POST", body: body, token: token) { [weak self] success, json, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success {
                    print("✅ Child added successfully")
                    completion(true, nil)
                } else {
                    print("❌ Failed to add child: \(error ?? "Unknown error")")
                    completion(false, error ?? "Failed to add child.")
                }
            }
        }
    }
    
    // MARK: - FETCH CHILDREN (protected by JWT)
    func fetchChildren() {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            print("❌ No token found for fetching children")
            return
        }

        let endpoint = "\(parentBaseURL)/children"
        
        sendRequest(urlString: endpoint, method: "GET", token: token) { [weak self] success, json, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if success, let json = json {
                    // Backend returns an array of children
                    if let children = json["children"] as? [[String: Any]] {
                        self.childrenList = children
                        print("✅ Fetched \(children.count) children")
                    } else {
                        self.childrenList = []
                        print("⚠️ No children found in response")
                    }
                } else {
                    print("❌ Failed to fetch children: \(error ?? "Unknown error")")
                    self.errorMessage = error ?? "Failed to fetch children."
                }
            }
        }
    }
    
    // MARK: - FETCH PARENT PROFILE
    func fetchParentProfile() {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            print("❌ No token found for parent profile")
            return
        }

        let endpoint = "\(baseURL)/profile/parent"
        
        sendRequest(urlString: endpoint, method: "GET", token: token) { [weak self] success, json, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if success, let json = json {
                    self.isParent = true
                    self.userProfile = json
                    self.parentEmail = json["email"] as? String ?? ""
                    self.parentPhone = json["phone"] as? String ?? ""
                    self.avatarURL = json["avatar"] as? String
                    
                    if let child = json["child"] as? [String: Any] {
                        self.childUsername = child["username"] as? String ?? ""
                        if let age = child["age"] as? Int { self.age = "\(age)" }
                        self.childGender = child["gender"] as? String ?? "Boy"
                        self.currentChildId = child["_id"] as? String ?? child["id"] as? String
                    }
                    print("✅ Parent profile fetched successfully")
                    print("   📧 Email: \(self.parentEmail)")
                    print("   👶 Child: \(self.childUsername)")
                    print("   🖼️ Avatar URL: \(self.avatarURL ?? "nil")")
                } else {
                    print("❌ Failed to fetch parent profile: \(error ?? "Unknown error")")
                    self.errorMessage = error ?? "Failed to fetch profile."
                }
            }
        }
    }
    
    // MARK: - FETCH CHILD PROFILE
    func fetchChildProfile() {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            print("❌ No token found for child profile")
            return
        }

        let endpoint = "\(baseURL)/profile/child"
        
        sendRequest(urlString: endpoint, method: "GET", token: token) { [weak self] success, json, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if success, let json = json {
                    print("🔍 Raw JSON received:")
                    print("   All keys: \(json.keys)")
                    print("   Full JSON: \(json)")
                    
                    self.isParent = false
                    self.userProfile = json
                    
                    // Essayer différents noms possibles pour l'avatar
                    if let avatar = json["avatar"] as? String {
                        self.avatarURL = avatar
                        print("   ✅ Found avatar field: \(avatar)")
                    } else if let avatar = json["avatarURL"] as? String {
                        self.avatarURL = avatar
                        print("   ✅ Found avatarURL field: \(avatar)")
                    } else if let avatar = json["profileImage"] as? String {
                        self.avatarURL = avatar
                        print("   ✅ Found profileImage field: \(avatar)")
                    } else if let avatar = json["image"] as? String {
                        self.avatarURL = avatar
                        print("   ✅ Found image field: \(avatar)")
                    } else if let avatar = json["photo"] as? String {
                        self.avatarURL = avatar
                        print("   ✅ Found photo field: \(avatar)")
                    } else {
                        print("   ⚠️ No avatar field found in response")
                        self.avatarURL = nil
                    }
                    
                    // Essayer de récupérer l'ID de plusieurs façons
                    if let id = json["_id"] as? String {
                        self.currentChildId = id
                        print("   ✅ Child ID found as '_id': \(id)")
                    } else if let id = json["id"] as? String {
                        self.currentChildId = id
                        print("   ✅ Child ID found as 'id': \(id)")
                    } else {
                        print("   ❌ WARNING: Could not find child ID in response!")
                    }
                    
                    self.childUsername = json["username"] as? String ?? ""
                    self.childGender = json["gender"] as? String ?? "Boy"
                    if let age = json["age"] as? Int { self.age = "\(age)" }
                    
                    print("✅ Child profile fetched successfully")
                    print("   👶 Username: \(self.childUsername)")
                    print("   🆔 ID: \(self.currentChildId ?? "N/A")")
                    print("   🎂 Age: \(self.age)")
                    print("   🖼️ Avatar URL: \(self.avatarURL ?? "nil")")
                } else {
                    print("❌ Failed to fetch child profile: \(error ?? "Unknown error")")
                    self.errorMessage = error ?? "Failed to fetch profile."
                }
            }
        }
    }
    
    // MARK: - FETCH PROFILE (fallback pour compatibilité)
    func fetchProfile() {
        if isParent {
            fetchParentProfile()
        } else {
            fetchChildProfile()
        }
    }

    // MARK: - LOGOUT
    func logout() {
        identifier = ""; password = ""; confirmPassword = ""
        age = ""; parentEmail = ""; parentPhone = ""
        childUsername = ""; childGender = "Boy"
        userProfile = [:]; isLoggedIn = false; isParent = false; currentChildId = nil
        UserDefaults.standard.removeObject(forKey: "jwt")
        UserDefaults.standard.removeObject(forKey: "rememberMe")
        UserDefaults.standard.removeObject(forKey: "savedIdentifier")
        UserDefaults.standard.removeObject(forKey: "isParent")
    }
    
    // MARK: - RESTORE SESSION (on app launch)
    func restoreSession() {
        print("🔄 Attempting to restore session...")
        
        guard UserDefaults.standard.bool(forKey: "rememberMe") else {
            print("⚠️ Remember Me not enabled, skipping session restore")
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            print("⚠️ No saved token found")
            return
        }
        
        let wasParent = UserDefaults.standard.bool(forKey: "isParent")
        
        print("✅ Session found! Restoring as \(wasParent ? "Parent" : "Child")")
        
        // Restaurer la session
        self.isParent = wasParent
        self.isLoggedIn = true
        
        // Récupérer le profil
        if wasParent {
            print("📧 Fetching parent profile...")
            self.fetchParentProfile()
        } else {
            print("👶 Fetching child profile...")
            self.fetchChildProfile()
        }
    }
    
    // MARK: - UPDATE PROFILE
    func updateProfile(completion: @escaping (Bool, String?) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            completion(false, "No token found")
            return
        }
        
        let endpoint = isParent ? "\(baseURL)/profile/parent/updateProfile" : "\(baseURL)/profile/child"
        var body: [String: Any] = [:]
        
        if isParent {
            body["email"] = parentEmail
            body["phone"] = parentPhone
        } else {
            body["username"] = childUsername
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
            print("❌ Invalid URL: \(urlString)")
            completion(false, nil, "Invalid URL")
            return
        }
        
        print("🌐 API Request: \(method) \(urlString)")
        if let token = token {
            print("🔑 Token: \(token.prefix(20))...")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            print("📤 Body: \(body)")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(false, nil, "Network error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                completion(false, nil, "Invalid response")
                return
            }
            
            print("📥 Response Status: \(httpResponse.statusCode)")
            
            let json = data.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }
            let message = json?["message"] as? String
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response Body: \(responseString)")
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                print("✅ Request successful")
                completion(true, json, nil)
            } else {
                print("❌ Request failed with status \(httpResponse.statusCode): \(message ?? "Unknown error")")
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
    
    // MARK: - QR TOKEN EXCHANGE (for child login via QR)
    func exchangeQrToken(_ token: String, completion: @escaping (Bool, String?) -> Void) {
        guard !token.isEmpty else {
            completion(false, "Token is empty")
            return
        }
        
        isLoading = true
        let endpoint = qrExchangeURL
        let body: [String: Any] = ["token": token]
        
        sendRequest(urlString: endpoint, body: body) { [weak self] success, json, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                if success, let accessToken = json?["access_token"] as? String {
                    print("✅ QR token exchange successful, token saved")
                    UserDefaults.standard.set(accessToken, forKey: "jwt")
                    self.isParent = false
                    self.isLoggedIn = true
                    
                    // Fetch child profile
                    print("👶 Fetching child profile after QR login...")
                    self.fetchChildProfile()
                    
                    completion(true, nil)
                } else {
                    print("❌ QR token exchange failed: \(error ?? "Unknown error")")
                    completion(false, error ?? "Failed to authenticate with QR code")
                }
            }
        }
    }
}
