import Foundation

struct APIConfig {
    // Utilisez votre adresse IP locale actuelle (changez si votre IP change)
    // static let baseURL = "http://172.18.15.74:3000"
    static let baseURL = "http://192.168.1.13:3000"
    
    // Endpoints existants
    static let qrBaseURL = "\(baseURL)/qr"
    static let authBaseURL = "\(baseURL)/auth"
    static let memoryGameBaseURL = "\(baseURL)/memory-game"
    
    // Nouveau endpoint pour les jeux AI
    static let aiGamesBaseURL = "\(baseURL)/ai-games"
    static let apiBaseURL = "\(baseURL)/api"
    
    // Endpoint pour les rapports AI
    static let reportsBaseURL = "\(baseURL)/reports"
    
    // Méthode helper pour vérifier si on est en mode debug
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    // Méthode pour logs de debug
    static func log(_ message: String) {
        if isDebug {
            print("🌐 APIConfig: \(message)")
        }
    }
}
