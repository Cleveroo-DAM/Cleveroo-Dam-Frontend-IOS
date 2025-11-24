# Architecture Diagram

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        CleverooDAMApp                           │
│                     (Main Entry Point)                          │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                      TabView                            │  │
│  │  ┌─────────────────────┐  ┌─────────────────────────┐  │  │
│  │  │  Mental Math Tab    │  │    AI Games Tab         │  │  │
│  │  └─────────────────────┘  └─────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┴───────────────────┐
        │                                       │
        ▼                                       ▼
┌──────────────────┐                  ┌──────────────────┐
│  Mental Math     │                  │    AI Games      │
│  Feature Module  │                  │  Feature Module  │
└──────────────────┘                  └──────────────────┘
```

## Feature Module Architecture (MVVM Pattern)

```
┌─────────────────────────────────────────────────────────────┐
│                        VIEW LAYER                           │
│                      (SwiftUI Views)                        │
│                                                             │
│  Mental Math:                    AI Games:                 │
│  • MentalMathGameView           • AIGameListView          │
│                                 • AIGamePlayView           │
│                                                             │
│  - User interactions            - Display game lists       │
│  - Question display             - Game generation UI       │
│  - Timer display                - Gameplay interface       │
│  - Results screen               - Progress tracking        │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ @StateObject / @ObservedObject
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                     VIEWMODEL LAYER                         │
│                   (Business Logic)                          │
│                                                             │
│  Mental Math:                    AI Games:                 │
│  • MentalMathGameViewModel      • AIGameViewModel         │
│                                                             │
│  - Game state management        - Game browsing logic      │
│  - Timer management             - Session management       │
│  - Score calculation            - Challenge validation     │
│  - Answer validation            - Event tracking           │
│  - @Published properties        - Level progression        │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ Combine Publishers
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                     SERVICE LAYER                           │
│                  (API Communication)                        │
│                                                             │
│  Mental Math:                    AI Games:                 │
│  • MentalMathService             • AIGamesService          │
│                                                             │
│  - startSession()               - listGames()              │
│  - getQuestion()                - generateGame()           │
│  - submitAnswer()               - startSession()           │
│  - endSession()                 - submitChallenge()        │
│  - getProgress()                - trackEvent()             │
│  - getReport()                  - getProgress()            │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ HTTP Requests
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                     NETWORKING LAYER                        │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              APIClient (Singleton)                  │  │
│  │                                                     │  │
│  │  • Generic request<T>() method                     │  │
│  │  • Authentication token management                 │  │
│  │  • JSON encoding/decoding                          │  │
│  │  • Error handling                                  │  │
│  │  • Combine Publishers                              │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │        APIClient+Extensions                         │  │
│  │                                                     │  │
│  │  • MentalMathEndpoint enum                         │  │
│  │  • AIGamesEndpoint enum                            │  │
│  │  • Endpoint path definitions                       │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ HTTPS
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    NestJS BACKEND API                       │
│                  api.cleveroodam.com                        │
│                                                             │
│  Mental Math Endpoints:          AI Games Endpoints:       │
│  • /api/mental-math/...         • /api/ai-games/...       │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### Request Flow (User Action → Backend)

```
User Interaction
    │
    ▼
SwiftUI View
    │ Action (e.g., button tap)
    ▼
ViewModel
    │ Call service method
    ▼
Service Layer
    │ Create Publisher
    ▼
APIClient
    │ Create URLRequest
    │ Add auth token
    │ Encode body
    ▼
Network (URLSession)
    │ HTTPS Request
    ▼
Backend API
```

### Response Flow (Backend → UI Update)

```
Backend API
    │ JSON Response
    ▼
Network (URLSession)
    │ Data + HTTPURLResponse
    ▼
APIClient
    │ Validate status code
    │ Decode JSON to Model
    ▼
Combine Publisher
    │ emit value / error
    ▼
Service Layer
    │ Forward Publisher
    ▼
ViewModel
    │ .sink() handler
    │ Update @Published properties
    ▼
SwiftUI View
    │ Automatic UI update
    ▼
User sees result
```

## Model Structure

### Mental Math Models

```
MathQuestion
├── id: String
├── question: String
├── correctAnswer: Int
├── difficulty: Difficulty
└── timeLimit: Int

MentalMathSession
├── id: String
├── childId: String
├── startTime: Date
├── endTime: Date?
├── questions: [SessionQuestion]
├── totalScore: Int
└── isCompleted: Bool

MentalMathProgress
├── childId: String
├── totalSessions: Int
├── totalQuestionsAnswered: Int
├── correctAnswers: Int
├── averageScore: Double
└── accuracyPercentage (computed)
```

### AI Games Models

```
AIGame
├── id: String
├── title: String
├── gameType: GameType
├── difficulty: Difficulty
├── ageRange: AgeRange
├── personalityTraits: [PersonalityTrait]
└── content: GameContent
    ├── levels: [GameLevel]
    │   ├── levelNumber: Int
    │   └── challenges: [Challenge]
    └── assets: [String: String]

AIGameSession
├── id: String
├── gameId: String
├── childId: String
├── currentLevel: Int
├── completedChallenges: [CompletedChallenge]
├── score: Int
├── events: [GameEvent]
└── isCompleted: Bool

AIGameProgress
├── childId: String
├── totalGamesPlayed: Int
├── totalGamesCompleted: Int
├── traitAssessments: [TraitAssessment]
└── completionRate (computed)
```

## Key Design Patterns

### 1. MVVM (Model-View-ViewModel)
- **View**: SwiftUI views (declarative UI)
- **ViewModel**: ObservableObject with @Published properties
- **Model**: Codable structs for data

### 2. Repository Pattern
- Service layer abstracts API communication
- ViewModels don't know about HTTP details

### 3. Reactive Programming (Combine)
- All async operations return Publishers
- ViewModels subscribe and update state
- SwiftUI automatically updates UI

### 4. Dependency Injection
- Services injected into ViewModels
- Easy to mock for testing
- Loose coupling

### 5. Singleton (for APIClient)
- Single instance for network operations
- Centralized configuration
- Shared authentication state

## Thread Safety

```
┌─────────────────────┐
│   Background Thread │
│                     │
│  URLSession tasks  │
│  Network I/O       │
└─────────────────────┘
          │
          │ .receive(on: DispatchQueue.main)
          ▼
┌─────────────────────┐
│    Main Thread      │
│                     │
│  ViewModel updates │
│  @Published props  │
│  UI updates        │
└─────────────────────┘
```

All ViewModel properties are updated on the main thread using `.receive(on: DispatchQueue.main)` to ensure thread-safe UI updates.

## Error Handling

```
Network Error
    │
    ▼
APIClient catches error
    │
    ▼
Convert to APIError enum
    │
    ▼
Emit through Publisher
    │
    ▼
Service forwards error
    │
    ▼
ViewModel catches error
    │
    ▼
Update @Published error property
    │
    ▼
View displays error UI
```

## Configuration Management

```
AppConstants
├── Timing
│   ├── feedbackDisplayDuration
│   ├── levelTransitionDuration
│   ├── mentalMathFeedbackDuration
│   └── aiGameFeedbackDuration
├── Defaults
│   ├── timeoutDefaultAnswer
│   └── mentalMathQuestionCount
└── API
    └── defaultBaseURL
```

All magic numbers extracted to centralized constants for easy configuration and maintenance.

## Testing Strategy

```
┌─────────────────────────────────────────┐
│           Unit Tests                    │
├─────────────────────────────────────────┤
│ • Model creation and validation        │
│ • Computed properties                  │
│ • Business logic in ViewModels         │
│ • API endpoint paths                   │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│       Integration Tests (Future)        │
├─────────────────────────────────────────┤
│ • Service → APIClient → Mock backend  │
│ • ViewModel → Service integration     │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│          UI Tests (Future)              │
├─────────────────────────────────────────┤
│ • SwiftUI view interactions           │
│ • User flows                          │
└─────────────────────────────────────────┘
```

## Build and Deployment

```
Development
    │
    ▼
Swift Package Manager (SPM)
    │
    ▼
Xcode Build
    │
    ▼
Debug Build (.app)
    │
    ▼
iOS Simulator / Device
    
Production
    │
    ▼
Xcode Archive
    │
    ▼
Code Signing
    │
    ▼
App Store Connect
    │
    ▼
TestFlight / App Store
```

## Security Considerations

1. **HTTPS Only**: All API communication over TLS
2. **Token Authentication**: Bearer token in headers
3. **No Hardcoded Secrets**: Configuration from environment
4. **Input Validation**: All user input validated
5. **Error Sanitization**: No sensitive data in error messages

## Performance Optimizations

1. **Lazy Loading**: ViewModels loaded only when needed
2. **Combine Cancellables**: Automatic memory management
3. **Weak References**: Avoid retain cycles in closures
4. **Efficient JSON**: Codable for fast encoding/decoding
5. **State Management**: Minimal re-renders with @Published
