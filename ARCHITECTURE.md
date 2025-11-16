# Cleveroo iOS - Architecture Documentation

## Overview

The Cleveroo iOS app follows the **MVVM (Model-View-ViewModel)** architectural pattern, providing a clean separation of concerns and making the codebase maintainable and testable.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         SwiftUI Views                        │
│  (Presentation Layer - UI Components)                        │
├─────────────────────────────────────────────────────────────┤
│  • LoginView          • RegisterParentView                   │
│  • ParentDashboardView • ChildDashboardView                  │
│  • AddChildView                                              │
└───────────────────────┬─────────────────────────────────────┘
                        │ @Published Properties
                        │ @EnvironmentObject
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                      ViewModels                              │
│  (Business Logic Layer)                                      │
├─────────────────────────────────────────────────────────────┤
│                    AuthViewModel                             │
│  • Authentication State Management                           │
│  • API Communication                                         │
│  • Data Transformation                                       │
│  • Error Handling                                            │
└───────────────────────┬─────────────────────────────────────┘
                        │ URLSession Requests
                        │ JSON Encoding/Decoding
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                         Models                               │
│  (Data Layer - Structures)                                   │
├─────────────────────────────────────────────────────────────┤
│  Request Models:                                             │
│  • ParentRegisterRequest  • LoginParentRequest               │
│  • LoginChildRequest      • AddChildRequest                  │
│                                                              │
│  Response Models:                                            │
│  • AuthResponse  • ParentInfo  • ChildInfo                   │
│  • ChildResponse • ErrorResponse                             │
└───────────────────────┬─────────────────────────────────────┘
                        │ Network Layer
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                    Backend API                               │
│  (NestJS Server - http://localhost:3000)                     │
├─────────────────────────────────────────────────────────────┤
│  Authentication:                                             │
│  • POST /auth/register                                       │
│  • POST /auth/login/parent                                   │
│  • POST /auth/login/child                                    │
│                                                              │
│  Protected Operations (JWT):                                 │
│  • POST /parent/children                                     │
│  • GET /parent/children                                      │
└─────────────────────────────────────────────────────────────┘
```

## Layer Details

### 1. View Layer (SwiftUI)

**Responsibilities:**
- Display UI components
- Handle user interactions
- Observe ViewModel state changes
- Present data from ViewModel

**Key Views:**

```swift
LoginView
├── Segmented control (Parent/Child)
├── Email/Username TextField
├── Password SecureField
└── Login Button → AuthViewModel.loginParent/loginChild()

RegisterParentView
├── Email TextField
├── Phone TextField
├── Password SecureField
├── Confirm Password SecureField
└── Sign Up Button → AuthViewModel.registerParent()

ParentDashboardView
├── Header with Logout
├── Children List (ScrollView)
│   └── ChildCard (foreach child)
└── Floating Action Button → Navigate to AddChildView

AddChildView
├── Username TextField
├── Age TextField
├── Gender Picker (Boy/Girl)
└── Add Child Button → AuthViewModel.addChild()

ChildDashboardView
├── Header with Logout
└── Welcome Message
```

### 2. ViewModel Layer

**AuthViewModel (ObservableObject)**

**Published Properties:**
```swift
@Published var isAuthenticated: Bool
@Published var isLoading: Bool
@Published var errorMessage: String?
@Published var childrenList: [[String: Any]]
@Published var currentUserType: UserType?
@Published var accessToken: String?
```

**Methods:**
```swift
// Authentication
func registerParent(email:phone:password:confirmPassword:completion:)
func loginParent(email:password:completion:)
func loginChild(username:password:completion:)

// Child Management (JWT Protected)
func addChild(username:age:gender:completion:)
func fetchChildren()

// Session Management
func logout()
```

**State Management Flow:**
```
User Action → View calls ViewModel method
            ↓
ViewModel sets isLoading = true
            ↓
ViewModel makes API call
            ↓
ViewModel processes response
            ↓
ViewModel updates @Published properties
            ↓
SwiftUI View automatically refreshes
```

### 3. Model Layer

**Request Models (Encodable):**
```swift
ParentRegisterRequest
├── email: String
├── phone: String
├── password: String
└── confirmPassword: String

LoginParentRequest
├── email: String
└── password: String

LoginChildRequest
├── username: String
└── password: String

AddChildRequest
├── username: String
├── age: Int
└── gender: String
```

**Response Models (Decodable):**
```swift
AuthResponse
├── access_token: String
├── token_type: String
├── parent: ParentInfo?
└── child: ChildInfo?

ChildResponse
├── id: String
├── username: String
├── age: Int
├── gender: String
└── avatar: String?
```

## Data Flow Diagrams

### Parent Registration Flow

```
RegisterParentView
       │
       │ User taps "Sign Up"
       ▼
AuthViewModel.registerParent()
       │
       │ Validation (client-side)
       ├─ Empty fields? → Error
       ├─ Passwords match? → Error
       │
       ▼
POST /auth/register
       │
       ├─ 201 Created → Success Alert → Navigate to Login
       └─ 4xx/5xx → Display Error Message
```

### Parent Login Flow

```
LoginView (Parent Tab)
       │
       │ User taps "Login"
       ▼
AuthViewModel.loginParent()
       │
       │ Validation
       ▼
POST /auth/login/parent
       │
       ├─ 200 OK
       │    ├─ Store access_token
       │    ├─ Set isAuthenticated = true
       │    ├─ Set currentUserType = .parent
       │    └─ Navigate to ParentDashboardView
       │
       └─ Error → Display Error Message
```

### Add Child Flow

```
ParentDashboardView
       │
       │ User taps FAB "+"
       ▼
AddChildView
       │
       │ User fills form and taps "Add Child"
       ▼
AuthViewModel.addChild()
       │
       │ Validation
       ▼
POST /parent/children
Headers: Authorization: Bearer {token}
       │
       ├─ 201 Created
       │    ├─ Success Alert
       │    ├─ Dismiss AddChildView
       │    └─ Auto-refresh children list
       │
       └─ Error → Display Error Message
```

### Fetch Children Flow

```
ParentDashboardView.onAppear
       │
       ▼
AuthViewModel.fetchChildren()
       │
       ▼
GET /parent/children
Headers: Authorization: Bearer {token}
       │
       ├─ 200 OK
       │    ├─ Parse JSON response
       │    ├─ Update childrenList
       │    └─ SwiftUI redraws UI
       │
       └─ Error → Display Error Message
```

### Child Login Flow

```
LoginView (Child Tab)
       │
       │ User taps "Login"
       ▼
AuthViewModel.loginChild()
       │
       │ Validation
       ▼
POST /auth/login/child
       │
       ├─ 200 OK
       │    ├─ Store access_token
       │    ├─ Set isAuthenticated = true
       │    ├─ Set currentUserType = .child
       │    └─ Navigate to ChildDashboardView
       │
       └─ Error → Display Error Message
```

## Navigation Structure

```
ContentView
    │
    └─> LoginView
           │
           ├─> [Sheet] RegisterParentView
           │       │
           │       └─> Dismiss → Back to LoginView
           │
           ├─> [NavigationLink] ParentDashboardView (after parent login)
           │       │
           │       ├─> [Sheet] AddChildView
           │       │       │
           │       │       └─> Dismiss → Back to Dashboard
           │       │
           │       └─> Logout → Back to LoginView
           │
           └─> [NavigationLink] ChildDashboardView (after child login)
                   │
                   └─> Logout → Back to LoginView
```

## State Management

### Authentication State

```swift
enum UserType {
    case parent
    case child
}

class AuthViewModel {
    @Published var isAuthenticated: Bool = false
    @Published var currentUserType: UserType? = nil
    @Published var accessToken: String? = nil
}
```

**State Transitions:**

```
Initial State:
├─ isAuthenticated = false
├─ currentUserType = nil
└─ accessToken = nil

After Successful Parent Login:
├─ isAuthenticated = true
├─ currentUserType = .parent
└─ accessToken = "jwt_token_here"

After Successful Child Login:
├─ isAuthenticated = true
├─ currentUserType = .child
└─ accessToken = "jwt_token_here"

After Logout:
├─ isAuthenticated = false
├─ currentUserType = nil
├─ accessToken = nil
└─ childrenList = []
```

## Error Handling Strategy

### Error Types

1. **Client-Side Validation Errors**
   - Empty fields
   - Password mismatch
   - Invalid age
   - Handled before API call

2. **Network Errors**
   - No internet connection
   - Timeout
   - DNS resolution failure
   - Display: "Network error: {description}"

3. **API Errors (4xx, 5xx)**
   - Parse ErrorResponse from backend
   - Display: Backend error message
   - Fallback: Generic error with status code

### Error Flow

```
API Call
   │
   ├─ Network Error?
   │   └─> Display: "Network error: {description}"
   │
   ├─ HTTP Status >= 400?
   │   ├─> Try parse ErrorResponse
   │   │   ├─ Success → Display: response.message
   │   │   └─ Fail → Display: "Request failed: {statusCode}"
   │   
   └─> Success (200/201)
       └─> Process response
```

## Security Considerations

### Token Management

```
Token Lifecycle:
1. Obtain → Store in @Published var accessToken
2. Use → Include in Authorization header
3. Clear → Set to nil on logout

Current: Memory only (session-based)
Future: Persist to Keychain for auto-login
```

### Password Security

```
• Passwords never stored locally
• SecureField used for input
• Transmitted only via API
• Backend handles hashing
```

### Network Security

```
Development:
• HTTP allowed for localhost testing
• NSAllowsArbitraryLoads = true in Info.plist

Production (TODO):
• Use HTTPS exclusively
• Remove NSAllowsArbitraryLoads
• Implement SSL pinning
• Certificate validation
```

## Design System

### Color Palette

```swift
Primary Gradient:
├─ Start: Color(hex: "9C27B0").opacity(0.9)  // Purple
└─ End: Color(hex: "98FF98").opacity(0.6)    // Light Green

UI Elements:
├─ Text Fields: Color.white.opacity(0.9)
├─ Cards: Color.white.opacity(0.2)
├─ Buttons: Color(hex: "9C27B0")
└─ Text: Color.white
```

### Component Styling

```swift
Buttons:
├─ Height: 50pt
├─ Corner Radius: 25pt
└─ Background: Solid or gradient

Text Fields:
├─ Padding: Standard
├─ Background: White 90% opacity
└─ Corner Radius: 10pt

Cards:
├─ Padding: Standard
├─ Background: White 20% opacity
└─ Corner Radius: 15pt

FAB:
├─ Size: 60x60pt
├─ Shape: Circle
├─ Shadow: Yes
└─ Background: Purple
```

## Performance Considerations

### Loading States

```swift
All async operations:
├─ Set isLoading = true before API call
├─ Display ProgressView in UI
├─ Set isLoading = false after response
└─ Keep UI responsive
```

### Memory Management

```swift
URLSession tasks:
├─ Use [weak self] in closures
└─ Properly handle task lifecycle

View lifecycle:
├─ Use .onAppear for data fetching
├─ Use .onDisappear for cleanup
└─ Proper @StateObject vs @ObservedObject usage
```

## Future Enhancements

### Phase 1: Core Improvements
- [ ] Persist JWT token to Keychain
- [ ] Implement token refresh mechanism
- [ ] Add loading indicators for all operations
- [ ] Implement pull-to-refresh

### Phase 2: Features
- [ ] Profile picture upload
- [ ] Edit child information
- [ ] Delete child functionality
- [ ] Password reset flow
- [ ] Email verification

### Phase 3: Advanced
- [ ] Biometric authentication
- [ ] Offline support with local database
- [ ] Push notifications
- [ ] Deep linking
- [ ] Analytics integration

### Phase 4: Quality
- [ ] Unit tests for ViewModels
- [ ] UI tests for key flows
- [ ] Integration tests with mock server
- [ ] Accessibility improvements
- [ ] Localization support

## Testing Strategy

### Unit Testing (Future)

```swift
AuthViewModelTests:
├─ testRegisterParent_Success()
├─ testRegisterParent_PasswordMismatch()
├─ testLoginParent_Success()
├─ testLoginParent_InvalidCredentials()
├─ testAddChild_Success()
├─ testAddChild_Unauthorized()
├─ testFetchChildren_Success()
└─ testLogout()
```

### UI Testing (Future)

```swift
AuthenticationFlowTests:
├─ testCompleteParentRegistrationFlow()
├─ testCompleteParentLoginFlow()
├─ testCompleteChildLoginFlow()
├─ testAddChildFlow()
└─ testLogoutFlow()
```

## Deployment

### Development
```
Target: iOS 15.0+
Build Configuration: Debug
Backend URL: http://localhost:3000
ATS: Disabled for localhost
```

### Production
```
Target: iOS 15.0+
Build Configuration: Release
Backend URL: https://api.cleveroo.com
ATS: Enabled (HTTPS only)
Code Signing: Required
App Store: Submit for review
```

## Troubleshooting

### Common Issues

**1. "No such module SwiftUI"**
- Ensure Xcode 14.0+
- Check deployment target iOS 15.0+
- Clean build folder

**2. API Connection Failed**
- Verify backend is running
- Check base URL is correct
- Verify Info.plist ATS settings
- Check device/simulator network

**3. Token Issues**
- Token format: "Bearer {token}"
- Verify Authorization header
- Check token expiration
- Confirm endpoint requires auth

**4. UI Not Updating**
- Check @Published properties
- Verify @StateObject vs @ObservedObject
- Confirm DispatchQueue.main.async usage
- Check environmentObject passing

## Resources

- **Apple Documentation:** [SwiftUI](https://developer.apple.com/documentation/swiftui/)
- **MVVM Pattern:** [iOS Architecture Patterns](https://medium.com/ios-os-x-development/ios-architecture-patterns-ecba4c38de52)
- **Networking:** [URLSession](https://developer.apple.com/documentation/foundation/urlsession)
- **Authentication:** [JWT Introduction](https://jwt.io/introduction)

---

## Summary

The Cleveroo iOS app implements a clean, maintainable architecture that:
- Separates concerns (Model-View-ViewModel)
- Handles authentication and authorization
- Manages state effectively
- Provides good error handling
- Follows iOS best practices
- Is ready for future enhancements
