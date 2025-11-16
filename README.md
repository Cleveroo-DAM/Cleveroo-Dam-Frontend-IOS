# Cleveroo iOS App

iOS application for the Cleveroo learning platform, built with SwiftUI following the MVVM architecture pattern.

## Features

### Authentication
- **Parent Registration**: Parents can register with email, phone, and password
- **Parent Login**: Parents can log in using their email and password
- **Child Login**: Children can log in using their username and password (password is inherited from parent)

### Parent Dashboard
- View all registered children
- Add new children with username, age, and gender
- Beautiful gradient UI matching the Android app design

### Child Dashboard
- Simple welcome screen for children after login

## Architecture

The app follows the MVVM (Model-View-ViewModel) pattern:

```
Cleveroo/
├── Models/
│   └── AuthModels.swift          # Data models for API requests/responses
├── ViewModels/
│   └── AuthViewModel.swift       # Business logic for authentication
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift       # Login screen for parent/child
│   │   └── RegisterParentView.swift  # Parent registration screen
│   └── Dashboard/
│       ├── ParentDashboardView.swift # Parent's main screen
│       ├── ChildDashboardView.swift  # Child's main screen
│       └── AddChildView.swift        # Form to add a new child
├── Utils/
│   └── ColorExtension.swift      # Helper for hex color conversion
├── Assets.xcassets/              # App assets
├── CleverooApp.swift             # App entry point
└── ContentView.swift             # Main view
```

## Backend API Integration

The app connects to a NestJS backend with the following endpoints:

### Authentication
- `POST /auth/register` - Register a new parent
- `POST /auth/login/parent` - Parent login
- `POST /auth/login/child` - Child login

### Parent Operations (JWT Protected)
- `POST /parent/children` - Add a new child
- `GET /parent/children` - Get list of all children

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Configuration

Update the base URL in `AuthViewModel.swift` to point to your backend:

```swift
private let baseURL = "http://localhost:3000"
```

For iOS Simulator, if your backend is running on your local machine, use:
- `http://localhost:3000` - if backend is on the same machine
- `http://YOUR_IP_ADDRESS:3000` - if backend is on another machine

## Design

The app uses a purple-to-green gradient matching the Android version:
- Primary Purple: `#9C27B0`
- Secondary Green: `#98FF98`

## Security

- JWT tokens are stored in memory during the session
- Passwords are securely transmitted to the backend
- App Transport Security is configured to allow local development

## Future Enhancements

- [ ] Persist JWT tokens in Keychain
- [ ] Add profile picture upload for children
- [ ] Implement child dashboard features
- [ ] Add offline support
- [ ] Implement password reset functionality
- [ ] Add biometric authentication

## License

Copyright © 2024 Cleveroo DAM. All rights reserved.
