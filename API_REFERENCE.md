# API Reference

## Overview

This document provides a complete reference of all API endpoints and their corresponding models used in the Cleveroo DAM iOS application.

## Base Configuration

```swift
APIClient.shared.configure(
    baseURL: "https://api.cleveroodam.com",
    authToken: "Bearer <your-token>"
)
```

---

## Mental Math API

### Endpoints

#### 1. Start Session

**Endpoint:** `POST /api/mental-math/sessions/start`

**Request Body:**
```swift
StartSessionRequest(
    childId: String,
    difficulty: MathQuestion.Difficulty,  // .easy, .medium, .hard
    questionCount: Int = 10
)
```

**Response:**
```swift
MentalMathSession(
    id: String,
    childId: String,
    startTime: Date,
    endTime: Date?,
    questions: [SessionQuestion],
    totalScore: Int,
    isCompleted: Bool
)
```

**Usage:**
```swift
let service = MentalMathService()
let request = StartSessionRequest(
    childId: "child123",
    difficulty: .medium
)

service.startSession(request: request)
    .sink(
        receiveCompletion: { completion in
            // Handle completion
        },
        receiveValue: { session in
            print("Session started: \(session.id)")
        }
    )
```

---

#### 2. Get Question

**Endpoint:** `GET /api/mental-math/sessions/{sessionId}/question`

**Parameters:**
- `sessionId`: String - Session identifier

**Response:**
```swift
MathQuestion(
    id: String,
    question: String,          // e.g., "15 + 7"
    correctAnswer: Int,        // e.g., 22
    difficulty: Difficulty,    // .easy, .medium, .hard
    timeLimit: Int,           // seconds
    createdAt: Date
)
```

**Usage:**
```swift
service.getQuestion(sessionId: "session123")
    .sink(
        receiveCompletion: { completion in },
        receiveValue: { question in
            print("Question: \(question.question)")
        }
    )
```

---

#### 3. Submit Answer

**Endpoint:** `POST /api/mental-math/sessions/submit-answer`

**Request Body:**
```swift
SubmitAnswerRequest(
    sessionId: String,
    questionId: String,
    answer: Int,
    timeSpent: TimeInterval
)
```

**Response:**
```swift
SubmitAnswerResponse(
    isCorrect: Bool,
    correctAnswer: Int,
    pointsEarned: Int,
    totalScore: Int
)
```

**Usage:**
```swift
let request = SubmitAnswerRequest(
    sessionId: "session123",
    questionId: "question456",
    answer: 42,
    timeSpent: 8.5
)

service.submitAnswer(request: request)
    .sink(
        receiveCompletion: { completion in },
        receiveValue: { response in
            if response.isCorrect {
                print("Correct! Score: \(response.totalScore)")
            }
        }
    )
```

---

#### 4. End Session

**Endpoint:** `POST /api/mental-math/sessions/end`

**Request Body:**
```swift
EndSessionRequest(
    sessionId: String
)
```

**Response:**
```swift
MentalMathSession(
    id: String,
    childId: String,
    startTime: Date,
    endTime: Date,
    questions: [SessionQuestion],
    totalScore: Int,
    isCompleted: Bool = true
)
```

---

#### 5. Get Progress

**Endpoint:** `GET /api/mental-math/progress/{childId}`

**Parameters:**
- `childId`: String - Child identifier

**Response:**
```swift
MentalMathProgress(
    childId: String,
    totalSessions: Int,
    totalQuestionsAnswered: Int,
    correctAnswers: Int,
    averageScore: Double,
    averageTimePerQuestion: Double,
    lastPlayedAt: Date?,
    difficultyDistribution: [String: Int]
)

// Computed property:
progress.accuracyPercentage: Double  // 0-100
```

---

#### 6. Get Report

**Endpoint:** `GET /api/mental-math/reports/{childId}?period={period}`

**Parameters:**
- `childId`: String - Child identifier
- `period`: String - "daily", "weekly", or "monthly"

**Response:**
```swift
MentalMathReport(
    childId: String,
    childName: String,
    reportPeriod: ReportPeriod,  // .daily, .weekly, .monthly
    generatedAt: Date,
    progress: MentalMathProgress,
    recentSessions: [SessionSummary],
    strengths: [String],
    areasForImprovement: [String]
)
```

---

## AI Games API

### Endpoints

#### 1. List Games

**Endpoint:** `GET /api/ai-games?gameType={type}&difficulty={difficulty}`

**Query Parameters:**
- `gameType`: Optional - "puzzle", "memory", "logic", "creativity", "math", "language"
- `difficulty`: Optional - "easy", "medium", "hard"

**Response:**
```swift
[AIGame]  // Array of games

AIGame(
    id: String,
    title: String,
    description: String,
    gameType: GameType,
    difficulty: Difficulty,
    ageRange: AgeRange(min: Int, max: Int),
    estimatedDuration: Int,  // minutes
    personalityTraits: [PersonalityTrait],
    instructions: String,
    content: GameContent,
    createdAt: Date,
    isActive: Bool
)
```

**Usage:**
```swift
service.listGames(gameType: .puzzle, difficulty: .medium)
    .sink(
        receiveCompletion: { completion in },
        receiveValue: { games in
            print("Found \(games.count) games")
        }
    )
```

---

#### 2. Get Game

**Endpoint:** `GET /api/ai-games/{gameId}`

**Parameters:**
- `gameId`: String - Game identifier

**Response:**
```swift
AIGame(
    // Full game details including content
    content: GameContent(
        levels: [GameLevel],
        assets: [String: String],
        metadata: [String: String]
    )
)

GameLevel(
    id: String,
    levelNumber: Int,
    title: String,
    challenges: [Challenge],
    timeLimit: Int?
)

Challenge(
    id: String,
    prompt: String,
    type: ChallengeType,  // .multipleChoice, .freeText, etc.
    correctAnswer: String,
    options: [String]?,
    hints: [String]
)
```

---

#### 3. Generate Game

**Endpoint:** `POST /api/ai-games/generate`

**Request Body:**
```swift
GenerateGameRequest(
    childId: String,
    gameType: AIGame.GameType,
    difficulty: AIGame.Difficulty,
    ageRange: AIGame.AgeRange,
    focusTraits: [String]?  // Optional trait IDs
)
```

**Response:**
```swift
AIGame  // Newly generated game
```

**Usage:**
```swift
let request = GenerateGameRequest(
    childId: "child123",
    gameType: .puzzle,
    difficulty: .medium,
    ageRange: AIGame.AgeRange(min: 6, max: 10)
)

service.generateGame(request: request)
    .sink(
        receiveCompletion: { completion in },
        receiveValue: { game in
            print("Generated: \(game.title)")
        }
    )
```

---

#### 4. Start Game Session

**Endpoint:** `POST /api/ai-games/sessions/start`

**Request Body:**
```swift
StartGameSessionRequest(
    gameId: String,
    childId: String
)
```

**Response:**
```swift
AIGameSession(
    id: String,
    gameId: String,
    childId: String,
    startTime: Date,
    endTime: Date?,
    currentLevel: Int = 1,
    completedChallenges: [CompletedChallenge],
    score: Int = 0,
    events: [GameEvent],
    isCompleted: Bool = false
)
```

---

#### 5. Submit Challenge

**Endpoint:** `POST /api/ai-games/sessions/submit-challenge`

**Request Body:**
```swift
SubmitChallengeRequest(
    sessionId: String,
    challengeId: String,
    answer: String,
    timeSpent: TimeInterval,
    hintsUsed: Int = 0
)
```

**Response:**
```swift
SubmitChallengeResponse(
    isCorrect: Bool,
    correctAnswer: String,
    pointsEarned: Int,
    totalScore: Int,
    feedback: String,
    nextChallenge: Challenge?
)
```

---

#### 6. Track Event

**Endpoint:** `POST /api/ai-games/sessions/track-event`

**Request Body:**
```swift
TrackEventRequest(
    sessionId: String,
    eventType: GameEvent.EventType,
    data: [String: String] = [:]
)

// Event types:
enum EventType {
    case gameStarted
    case levelStarted
    case levelCompleted
    case challengeAttempted
    case challengeCompleted
    case hintRequested
    case pauseRequested
    case gameCompleted
    case gameAbandoned
}
```

**Response:**
```swift
Void  // No response body
```

---

#### 7. End Session

**Endpoint:** `POST /api/ai-games/sessions/{sessionId}/end`

**Parameters:**
- `sessionId`: String - Session identifier

**Response:**
```swift
AIGameSession(
    // Completed session with endTime and isCompleted = true
)
```

---

#### 8. Get Progress

**Endpoint:** `GET /api/ai-games/progress/{childId}`

**Parameters:**
- `childId`: String - Child identifier

**Response:**
```swift
AIGameProgress(
    childId: String,
    totalGamesPlayed: Int,
    totalGamesCompleted: Int,
    totalTimeSpent: TimeInterval,
    averageScore: Double,
    traitAssessments: [TraitAssessment],
    favoriteGameTypes: [AIGame.GameType],
    lastPlayedAt: Date?
)

// Computed property:
progress.completionRate: Double  // 0-100
```

---

#### 9. Get Trait Assessments

**Endpoint:** `GET /api/ai-games/assessments/{childId}`

**Parameters:**
- `childId`: String - Child identifier

**Response:**
```swift
[TraitAssessment]  // Array of assessments

TraitAssessment(
    traitId: String,
    traitName: String,
    score: Double,  // 0-100
    level: AssessmentLevel,  // .developing, .emerging, .proficient, .advanced
    observations: [String]
)
```

---

## Error Handling

All API requests can fail with `APIError`:

```swift
enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)
    case networkError(Error)
    case unauthorized
    case notFound
    case serverError
}
```

**Example Error Handling:**
```swift
service.startSession(request: request)
    .sink(
        receiveCompletion: { completion in
            if case .failure(let error) = completion {
                switch error {
                case .unauthorized:
                    print("Please log in")
                case .networkError(let underlyingError):
                    print("Network error: \(underlyingError)")
                case .httpError(let statusCode, let message):
                    print("HTTP \(statusCode): \(message ?? "")")
                default:
                    print("Error: \(error.localizedDescription)")
                }
            }
        },
        receiveValue: { session in
            // Success
        }
    )
    .store(in: &cancellables)
```

---

## Common Patterns

### Pattern 1: Simple Request

```swift
service.getProgress(childId: "child123")
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { completion in
            if case .failure(let error) = completion {
                self.error = error.localizedDescription
            }
        },
        receiveValue: { progress in
            self.progress = progress
        }
    )
    .store(in: &cancellables)
```

### Pattern 2: Chained Requests

```swift
// Start session, then load first question
service.startSession(request: startRequest)
    .flatMap { session -> AnyPublisher<MathQuestion, APIError> in
        self.currentSession = session
        return self.service.getQuestion(sessionId: session.id)
    }
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { completion in },
        receiveValue: { question in
            self.currentQuestion = question
        }
    )
    .store(in: &cancellables)
```

### Pattern 3: Fire and Forget (Events)

```swift
// Track event without waiting for response
service.trackEvent(request: eventRequest)
    .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    .store(in: &cancellables)
```

---

## Authentication

All requests automatically include the authentication token if set:

```swift
// Set token after login
APIClient.shared.setAuthToken("your-jwt-token")

// All subsequent requests will include:
// Authorization: Bearer your-jwt-token
```

---

## Rate Limiting

The API may implement rate limiting. Handle `429 Too Many Requests` errors:

```swift
if case .httpError(let statusCode, _) = error, statusCode == 429 {
    // Implement exponential backoff or show rate limit message
}
```

---

## Pagination

For endpoints that may return large datasets, consider implementing pagination:

```swift
// Future enhancement
service.getSessions(childId: "child123", page: 1, perPage: 20)
```

---

## Best Practices

1. **Always handle errors** - Use proper error handling in all API calls
2. **Update UI on main thread** - Use `.receive(on: DispatchQueue.main)`
3. **Store cancellables** - Keep references to prevent premature cancellation
4. **Validate input** - Check data before sending to API
5. **Use weak self** - Avoid retain cycles in closures
6. **Timeout handling** - Implement timeouts for long-running requests
7. **Offline support** - Cache data locally when possible
8. **Retry logic** - Implement automatic retries for transient failures

---

## Testing

Mock the service layer for unit tests:

```swift
class MockMentalMathService: MentalMathService {
    override func startSession(request: StartSessionRequest) 
        -> AnyPublisher<MentalMathSession, APIError> {
        // Return mock data
        Just(MentalMathSession(childId: request.childId))
            .setFailureType(to: APIError.self)
            .eraseToAnyPublisher()
    }
}
```

---

## Version Information

- **API Version:** 1.0
- **iOS Minimum:** 16.0
- **Swift Version:** 5.9+
- **Last Updated:** November 2025
