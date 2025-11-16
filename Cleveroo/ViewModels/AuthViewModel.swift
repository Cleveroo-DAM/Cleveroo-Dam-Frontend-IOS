//
//  AuthViewModel.swift
//  Cleveroo
//
//  ViewModel for authentication and user management
//

import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var childrenList: [[String: Any]] = []
    @Published var currentUserType: UserType?
    @Published var accessToken: String?
    
    private let baseURL = "http://localhost:3000"
    
    enum UserType {
        case parent
        case child
    }
    
    // MARK: - Register Parent
    
    func registerParent(email: String, phone: String, password: String, confirmPassword: String, completion: @escaping (Bool) -> Void) {
        guard !email.isEmpty, !phone.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "All fields are required"
            completion(false)
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let request = ParentRegisterRequest(email: email, phone: phone, password: password, confirmPassword: confirmPassword)
        
        guard let url = URL(string: "\(baseURL)/auth/register") else {
            errorMessage = "Invalid URL"
            isLoading = false
            completion(false)
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            errorMessage = "Failed to encode request"
            isLoading = false
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Invalid response"
                    completion(false)
                    return
                }
                
                if httpResponse.statusCode == 201 || httpResponse.statusCode == 200 {
                    completion(true)
                } else if let data = data {
                    if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        self?.errorMessage = errorResponse.message
                    } else {
                        self?.errorMessage = "Registration failed with status code: \(httpResponse.statusCode)"
                    }
                    completion(false)
                } else {
                    self?.errorMessage = "Registration failed"
                    completion(false)
                }
            }
        }.resume()
    }
    
    // MARK: - Login Parent
    
    func loginParent(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required"
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let request = LoginParentRequest(email: email, password: password)
        
        guard let url = URL(string: "\(baseURL)/auth/login/parent") else {
            errorMessage = "Invalid URL"
            isLoading = false
            completion(false)
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            errorMessage = "Failed to encode request"
            isLoading = false
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Invalid response"
                    completion(false)
                    return
                }
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    if let data = data {
                        do {
                            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                            self?.accessToken = authResponse.access_token
                            self?.isAuthenticated = true
                            self?.currentUserType = .parent
                            completion(true)
                        } catch {
                            self?.errorMessage = "Failed to decode response"
                            completion(false)
                        }
                    }
                } else if let data = data {
                    if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        self?.errorMessage = errorResponse.message
                    } else {
                        self?.errorMessage = "Login failed"
                    }
                    completion(false)
                } else {
                    self?.errorMessage = "Login failed"
                    completion(false)
                }
            }
        }.resume()
    }
    
    // MARK: - Login Child
    
    func loginChild(username: String, password: String, completion: @escaping (Bool) -> Void) {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Username and password are required"
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let request = LoginChildRequest(username: username, password: password)
        
        guard let url = URL(string: "\(baseURL)/auth/login/child") else {
            errorMessage = "Invalid URL"
            isLoading = false
            completion(false)
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            errorMessage = "Failed to encode request"
            isLoading = false
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Invalid response"
                    completion(false)
                    return
                }
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    if let data = data {
                        do {
                            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                            self?.accessToken = authResponse.access_token
                            self?.isAuthenticated = true
                            self?.currentUserType = .child
                            completion(true)
                        } catch {
                            self?.errorMessage = "Failed to decode response"
                            completion(false)
                        }
                    }
                } else if let data = data {
                    if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        self?.errorMessage = errorResponse.message
                    } else {
                        self?.errorMessage = "Login failed"
                    }
                    completion(false)
                } else {
                    self?.errorMessage = "Login failed"
                    completion(false)
                }
            }
        }.resume()
    }
    
    // MARK: - Add Child
    
    func addChild(username: String, age: Int, gender: String, completion: @escaping (Bool) -> Void) {
        guard let token = accessToken else {
            errorMessage = "Not authenticated"
            completion(false)
            return
        }
        
        guard !username.isEmpty, age > 0 else {
            errorMessage = "Invalid username or age"
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let request = AddChildRequest(username: username, age: age, gender: gender)
        
        guard let url = URL(string: "\(baseURL)/parent/children") else {
            errorMessage = "Invalid URL"
            isLoading = false
            completion(false)
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            errorMessage = "Failed to encode request"
            isLoading = false
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Invalid response"
                    completion(false)
                    return
                }
                
                if httpResponse.statusCode == 201 || httpResponse.statusCode == 200 {
                    completion(true)
                } else if let data = data {
                    if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        self?.errorMessage = errorResponse.message
                    } else {
                        self?.errorMessage = "Failed to add child"
                    }
                    completion(false)
                } else {
                    self?.errorMessage = "Failed to add child"
                    completion(false)
                }
            }
        }.resume()
    }
    
    // MARK: - Fetch Children
    
    func fetchChildren() {
        guard let token = accessToken else {
            errorMessage = "Not authenticated"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/parent/children") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Invalid response"
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    if let data = data {
                        do {
                            if let children = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                                self?.childrenList = children
                            } else if let childrenResponse = try? JSONDecoder().decode([ChildResponse].self, from: data) {
                                // Convert to dictionary format
                                self?.childrenList = childrenResponse.map { child in
                                    [
                                        "id": child.id,
                                        "username": child.username,
                                        "age": child.age,
                                        "gender": child.gender,
                                        "avatar": child.avatar ?? ""
                                    ]
                                }
                            }
                        } catch {
                            self?.errorMessage = "Failed to parse children list"
                        }
                    }
                } else if let data = data {
                    if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        self?.errorMessage = errorResponse.message
                    } else {
                        self?.errorMessage = "Failed to fetch children"
                    }
                }
            }
        }.resume()
    }
    
    // MARK: - Logout
    
    func logout() {
        isAuthenticated = false
        accessToken = nil
        currentUserType = nil
        childrenList = []
    }
}
