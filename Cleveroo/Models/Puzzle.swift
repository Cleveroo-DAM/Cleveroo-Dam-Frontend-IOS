import Foundation

// MARK: - Puzzle Models

struct Puzzle: Identifiable, Codable {
    let id: String
    let playerName: String
    var board: [[Int]]
    let gridSize: Int
    var moves: Int
    var completed: Bool
    let message: String?
    let emptyPosition: Position?
    let completionTime: Int?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case playerName
        case board
        case gridSize
        case moves
        case completed
        case message
        case emptyPosition
        case completionTime
        case createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        playerName = try container.decode(String.self, forKey: .playerName)
        board = try container.decode([[Int]].self, forKey: .board)
        gridSize = try container.decode(Int.self, forKey: .gridSize)
        moves = try container.decode(Int.self, forKey: .moves)
        completed = try container.decode(Bool.self, forKey: .completed)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        emptyPosition = try container.decodeIfPresent(Position.self, forKey: .emptyPosition)
        completionTime = try container.decodeIfPresent(Int.self, forKey: .completionTime)
        
        // Décoder la date depuis une String ISO 8601
        if let dateString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            let formatter = ISO8601DateFormatter()
            createdAt = formatter.date(from: dateString)
        } else {
            createdAt = nil
        }
    }
}

struct Position: Codable, Equatable {
    let row: Int
    let col: Int
}

struct CreatePuzzleRequest: Codable {
    let playerName: String
    let gridSize: Int
    
    enum CodingKeys: String, CodingKey {
        case playerName
        case gridSize
    }
}

struct MoveTileRequest: Codable {
    let row: Int
    let col: Int
}

struct LeaderboardEntry: Identifiable, Codable {
    let id = UUID()
    let rank: Int
    let playerName: String
    let moves: Int
    let gridSize: Int
    let completionTime: Int
    let completedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case rank
        case playerName
        case moves
        case gridSize
        case completionTime
        case completedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        rank = try container.decode(Int.self, forKey: .rank)
        playerName = try container.decode(String.self, forKey: .playerName)
        moves = try container.decode(Int.self, forKey: .moves)
        gridSize = try container.decode(Int.self, forKey: .gridSize)
        completionTime = try container.decode(Int.self, forKey: .completionTime)
        
        // Décoder la date depuis une String ISO 8601
        if let dateString = try container.decodeIfPresent(String.self, forKey: .completedAt) {
            let formatter = ISO8601DateFormatter()
            completedAt = formatter.date(from: dateString)
        } else {
            completedAt = nil
        }
    }
}
