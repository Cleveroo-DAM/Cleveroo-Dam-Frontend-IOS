import Foundation
import Combine

class PuzzleService {
    static let shared = PuzzleService()
    
    private let baseURL = APIConfig.baseURL
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Create Puzzle
    func createPuzzle(
        playerName: String,
        gridSize: Int,
        token: String
    ) -> AnyPublisher<Puzzle, Error> {
        let url = URL(string: "\(baseURL)/puzzle")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let dto = CreatePuzzleRequest(playerName: playerName, gridSize: gridSize)
        request.httpBody = try? JSONEncoder().encode(dto)
        
        print("🎮 PuzzleService: Creating puzzle - Size: \(gridSize)x\(gridSize), Player: \(playerName)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                print("📥 PuzzleService: Create response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 201 {
                    let errorStr = String(data: data, encoding: .utf8) ?? ""
                    print("❌ PuzzleService: Error - \(errorStr)")
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: Puzzle.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get Puzzle
    func getPuzzle(puzzleId: String, token: String) -> AnyPublisher<Puzzle, Error> {
        let url = URL(string: "\(baseURL)/puzzle/\(puzzleId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("🎮 PuzzleService: Getting puzzle - ID: \(puzzleId)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                print("📥 PuzzleService: Get puzzle status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: Puzzle.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Move Tile
    func moveTile(
        puzzleId: String,
        row: Int,
        col: Int,
        token: String
    ) -> AnyPublisher<Puzzle, Error> {
        let url = URL(string: "\(baseURL)/puzzle/\(puzzleId)/move")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let moveRequest = MoveTileRequest(row: row, col: col)
        request.httpBody = try? JSONEncoder().encode(moveRequest)
        
        print("🎮 PuzzleService: Moving tile - Row: \(row), Col: \(col)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                print("📥 PuzzleService: Move response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    let errorStr = String(data: data, encoding: .utf8) ?? ""
                    print("❌ PuzzleService: Move error - \(errorStr)")
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: Puzzle.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Reset Puzzle
    func resetPuzzle(puzzleId: String, token: String) -> AnyPublisher<Puzzle, Error> {
        let url = URL(string: "\(baseURL)/puzzle/\(puzzleId)/reset")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("🎮 PuzzleService: Resetting puzzle - ID: \(puzzleId)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                print("📥 PuzzleService: Reset response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: Puzzle.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Delete Puzzle
    func deletePuzzle(puzzleId: String, token: String) -> AnyPublisher<Void, Error> {
        let url = URL(string: "\(baseURL)/puzzle/\(puzzleId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("🎮 PuzzleService: Deleting puzzle - ID: \(puzzleId)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                print("📥 PuzzleService: Delete response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 204 {
                    throw URLError(.badServerResponse)
                }
                
                return ()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get Leaderboard
    func getLeaderboard(gridSize: Int? = nil, limit: Int = 10, token: String) -> AnyPublisher<[LeaderboardEntry], Error> {
        var urlString = "\(baseURL)/puzzle/leaderboard/top?limit=\(limit)"
        if let gridSize = gridSize {
            urlString += "&gridSize=\(gridSize)"
        }
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("🎮 PuzzleService: Getting leaderboard")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                print("📥 PuzzleService: Leaderboard status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: [LeaderboardEntry].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get All Available Puzzles
    func getAllPuzzles(token: String) -> AnyPublisher<[Puzzle], Error> {
        let url = URL(string: "\(baseURL)/puzzle")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("🎮 PuzzleService: Getting all available puzzles")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                print("📥 PuzzleService: All puzzles status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: [Puzzle].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get Assigned Puzzles for Child
    func getAssignedPuzzles(childId: String, token: String) -> AnyPublisher<[Puzzle], Error> {
        let url = URL(string: "\(baseURL)/puzzle/child/\(childId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("🎮 PuzzleService: Getting assigned puzzles for child - ID: \(childId)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                print("📥 PuzzleService: Assigned puzzles status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: [Puzzle].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
