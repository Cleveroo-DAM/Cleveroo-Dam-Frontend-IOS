//
//  APIService.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/11/2025.
//

import Foundation

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    func register(childUsername: String, password: String, age: Int, parentEmail: String, phone: String, completion: @escaping (Bool) -> Void) {
        // Simulation d’un appel réseau — à remplacer par ton endpoint NestJS
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            print("👶 Child: \(childUsername), Parent: \(parentEmail) enregistré.")
            completion(true)
        }
    }
    
    func login(role: String, identifier: String, password: String, completion: @escaping (Bool) -> Void) {
        // Simulation de connexion
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(true)
        }
    }
}
