//
//  MockAIGameService.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 24/11/2025.
//

import Foundation
import Combine

/// Service temporaire pour tester l'interface AI Games sans backend complet
class MockAIGameService: ObservableObject {
    static let shared = MockAIGameService()
    
    private init() {}
    
    // MARK: - Mock Data
    private let mockGames = [
        GeneratedGame(
            id: "mock_game_1",
            title: "Jeu de Personnalité",
            description: "Découvre ta personnalité à travers des choix amusants !",
            domain: "personality",
            recommendedAgeMin: 6,
            recommendedAgeMax: 10,
            durationSeconds: 300,
            spec: GameSpec(
                steps: [
                    GameStep(
                        id: "step1",
                        type: .choice,
                        prompt: "Quelle est ta couleur préférée ?",
                        options: ["Rouge", "Bleu", "Vert", "Jaune"],
                        timeLimitSeconds: nil,
                        scoring: GameScoring(type: "choice", traitWeights: ["openness": 1.0], direction: "higher_is_more_trait"),
                        metadata: nil
                    ),
                    GameStep(
                        id: "step2",
                        type: .question,
                        prompt: "Décris ton animal préféré en un mot",
                        options: nil,
                        timeLimitSeconds: nil,
                        scoring: GameScoring(type: "behavior", traitWeights: ["creativity": 1.0], direction: "higher_is_more_trait"),
                        metadata: nil
                    )
                ],
                metadata: nil
            ),
            meta: GameMeta(parentId: "mock_parent", aiGeneratedAt: "2025-11-24", notes: "Jeu généré par Mock")
        ),
        GeneratedGame(
            id: "mock_game_2",
            title: "Défi Créatif",
            description: "Laisse libre cours à ton imagination !",
            domain: "creativity",
            recommendedAgeMin: 7,
            recommendedAgeMax: 12,
            durationSeconds: 450,
            spec: GameSpec(
                steps: [
                    GameStep(
                        id: "step1",
                        type: .task,
                        prompt: "Dessine un animal imaginaire avec des super pouvoirs",
                        options: nil,
                        timeLimitSeconds: 180,
                        scoring: GameScoring(type: "behavior", traitWeights: ["creativity": 1.0, "openness": 0.5], direction: "higher_is_more_trait"),
                        metadata: nil
                    )
                ],
                metadata: nil
            ),
            meta: GameMeta(parentId: "mock_parent", aiGeneratedAt: "2025-11-24", notes: "Jeu créatif")
        )
    ]
    
    // MARK: - Mock Functions
    func generateGame(request: GenerateGameRequest, token: String) -> AnyPublisher<GeneratedGame, Error> {
        print("🎮 MockAIGameService: Generating mock game for domain: \(request.domain)")
        
        // Simuler un délai de génération
        return Just(())
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .tryMap { _ in
                // Créer un jeu mock basé sur la demande
                let mockGame = GeneratedGame(
                    id: "mock_\(UUID().uuidString.prefix(8))",
                    title: request.title ?? "Jeu \(request.domain.capitalized) Généré",
                    description: "Un jeu personnalisé pour développer \(self.getDomainDescription(request.domain))",
                    domain: request.domain,
                    recommendedAgeMin: request.recommendedAgeMin,
                    recommendedAgeMax: request.recommendedAgeMax,
                    durationSeconds: Int.random(in: 300...600),
                    spec: self.generateMockSpec(for: request.domain),
                    meta: GameMeta(
                        parentId: "current_parent",
                        aiGeneratedAt: ISO8601DateFormatter().string(from: Date()),
                        notes: request.constraints
                    )
                )
                
                print("✅ MockAIGameService: Generated game '\(mockGame.title)'")
                return mockGame
            }
            .eraseToAnyPublisher()
    }
    
    func getMyGames(token: String) -> AnyPublisher<GamesForChildResponse, Error> {
        print("🎮 MockAIGameService: Fetching mock games")
        
        return Just(GamesForChildResponse(
            games: mockGames,
            totalGames: mockGames.count,
            childAge: 8
        ))
        .setFailureType(to: Error.self)
        .delay(for: .seconds(1), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func startSession(gameId: String, token: String) -> AnyPublisher<StartSessionResponse, Error> {
        print("🎮 MockAIGameService: Starting mock session for game: \(gameId)")
        
        guard let game = mockGames.first(where: { $0.id == gameId }) else {
            return Fail(error: URLError(.fileDoesNotExist)).eraseToAnyPublisher()
        }
        
        let session = GameSession(
            id: "mock_session_\(UUID().uuidString.prefix(8))",
            childId: "mock_child",
            gameId: gameId,
            status: .inProgress,
            events: [],
            metrics: nil,
            personalityResult: nil,
            progress: SessionProgress(
                answeredSteps: 0,
                totalSteps: game.spec.steps.count,
                percent: 0,
                lastUpdatedAt: ISO8601DateFormatter().string(from: Date())
            )
        )
        
        return Just(StartSessionResponse(session: session, game: game))
            .setFailureType(to: Error.self)
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    private func getDomainDescription(_ domain: String) -> String {
        switch domain {
        case "personality": return "la personnalité"
        case "creativity": return "la créativité"
        case "attention": return "l'attention"
        case "social": return "les compétences sociales"
        default: return "différentes compétences"
        }
    }
    
    private func generateMockSpec(for domain: String) -> GameSpec {
        let steps: [GameStep]
        
        switch domain {
        case "personality":
            steps = [
                GameStep(
                    id: "p1",
                    type: .choice,
                    prompt: "Comment préfères-tu passer ton temps libre ?",
                    options: ["Lire un livre", "Jouer dehors", "Dessiner", "Jouer aux jeux vidéo"],
                    timeLimitSeconds: nil,
                    scoring: GameScoring(type: "choice", traitWeights: ["openness": 1.0, "extraversion": 0.5], direction: "higher_is_more_trait"),
                    metadata: nil
                ),
                GameStep(
                    id: "p2",
                    type: .choice,
                    prompt: "Tu vois un enfant qui pleure dans la cour. Que fais-tu ?",
                    options: ["Je vais le consoler", "Je demande de l'aide à un adulte", "Je continue à jouer"],
                    timeLimitSeconds: nil,
                    scoring: GameScoring(type: "choice", traitWeights: ["agreeableness": 1.0, "conscientiousness": 0.3], direction: "higher_is_more_trait"),
                    metadata: nil
                )
            ]
        case "creativity":
            steps = [
                GameStep(
                    id: "c1",
                    type: .task,
                    prompt: "Invente une histoire avec ces mots : robot, nuage, chocolat",
                    options: nil,
                    timeLimitSeconds: 120,
                    scoring: GameScoring(type: "behavior", traitWeights: ["creativity": 1.0, "openness": 0.8], direction: "higher_is_more_trait"),
                    metadata: nil
                ),
                GameStep(
                    id: "c2",
                    type: .question,
                    prompt: "Si tu pouvais créer un nouveau jouet, comment serait-il ?",
                    options: nil,
                    timeLimitSeconds: nil,
                    scoring: GameScoring(type: "behavior", traitWeights: ["creativity": 1.0], direction: "higher_is_more_trait"),
                    metadata: nil
                )
            ]
        case "attention":
            steps = [
                GameStep(
                    id: "a1",
                    type: .timedReaction,
                    prompt: "Appuie dès que tu vois l'étoile apparaître !",
                    options: nil,
                    timeLimitSeconds: 5,
                    scoring: GameScoring(type: "timed", traitWeights: ["attention": 1.0, "impulsivity": -0.3], direction: "higher_is_more_trait"),
                    metadata: nil
                ),
                GameStep(
                    id: "a2",
                    type: .choice,
                    prompt: "Combien de cercles rouges vois-tu dans cette image ?",
                    options: ["2", "3", "4", "5"],
                    timeLimitSeconds: 10,
                    scoring: GameScoring(type: "accuracy", traitWeights: ["attention": 1.0], direction: "higher_is_more_trait"),
                    metadata: nil
                )
            ]
        default:
            steps = [
                GameStep(
                    id: "default1",
                    type: .question,
                    prompt: "Raconte-moi quelque chose d'intéressant !",
                    options: nil,
                    timeLimitSeconds: nil,
                    scoring: GameScoring(type: "behavior", traitWeights: ["openness": 1.0], direction: "higher_is_more_trait"),
                    metadata: nil
                )
            ]
        }
        
        return GameSpec(steps: steps, metadata: nil)
    }
}
