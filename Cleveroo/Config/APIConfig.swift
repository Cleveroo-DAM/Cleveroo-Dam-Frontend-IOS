import Foundation

struct APIConfig {
    static let baseURL = "http://192.168.1.8:3000"
    static let qrBaseURL = "\(baseURL)/qr"
    static let authBaseURL = "\(baseURL)/auth"
    static let memoryGameBaseURL = "\(baseURL)/memory-game"
}
