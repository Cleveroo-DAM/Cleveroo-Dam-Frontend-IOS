# Cleveroo DAM Frontend iOS

iOS frontend for Cleveroo DAM (Digital Asset Management) system with Mental Math and AI Games features.

## Features

### Mental Math Game
- Timed mathematical challenges for children
- Multiple difficulty levels
- Progress tracking and analytics
- Parent reports

### AI Games
- AI-generated educational games
- Personality trait assessment
- Adaptive difficulty
- Session management and event tracking

## Architecture

This project follows clean architecture principles with:

- **Models**: Data structures for Mental Math and AI Games
- **Services**: Network layer for API communication
- **ViewModels**: Business logic with Combine framework
- **Views**: SwiftUI-based user interfaces

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Setup

```bash
# Clone the repository
git clone https://github.com/Cleveroo-DAM/Cleveroo-Dam-Frontend-IOS.git

# Open in Xcode
open Package.swift
```

## Project Structure

```
Sources/
├── CleverooDAMApp.swift          # Main app entry point
├── Networking/                    # API client and networking layer
│   ├── APIClient.swift
│   └── APIClient+Extensions.swift
├── MentalMath/
│   ├── Models/
│   │   └── MentalMathModels.swift
│   ├── Services/
│   │   └── MentalMathService.swift
│   ├── ViewModels/
│   │   └── MentalMathGameViewModel.swift
│   └── Views/
│       └── MentalMathGameView.swift
└── AIGames/
    ├── Models/
    │   └── AIGameModels.swift
    ├── Services/
    │   └── AIGamesService.swift
    ├── ViewModels/
    │   └── AIGameViewModel.swift
    └── Views/
        ├── AIGameListView.swift
        └── AIGamePlayView.swift
```

## Testing

```bash
swift test
```

## License

Proprietary - Cleveroo DAM
