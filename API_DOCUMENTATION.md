# Cleveroo iOS - API Integration Documentation

## Base URL

```
http://localhost:3000
```

For production, update the `baseURL` in `AuthViewModel.swift`.

---

## Authentication Endpoints

### 1. Register Parent

**Endpoint:** `POST /auth/register`

**Description:** Creates a new parent account with an empty children array.

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "parent@example.com",
  "phone": "+1234567890",
  "password": "SecurePassword123",
  "confirmPassword": "SecurePassword123"
}
```

**iOS Model:**
```swift
struct ParentRegisterRequest: Codable {
    let email: String
    let phone: String
    let password: String
    let confirmPassword: String
}
```

**Success Response (201 Created):**
```json
{
  "id": "parent_uuid",
  "email": "parent@example.com",
  "phone": "+1234567890",
  "children": []
}
```

**Error Responses:**
- `400 Bad Request` - Validation errors (missing fields, passwords don't match)
- `409 Conflict` - Email already exists

**iOS Implementation:**
```swift
authViewModel.registerParent(
    email: "parent@example.com",
    phone: "+1234567890",
    password: "SecurePassword123",
    confirmPassword: "SecurePassword123"
) { success in
    if success {
        // Registration successful
    }
}
```

---

### 2. Login Parent

**Endpoint:** `POST /auth/login/parent`

**Description:** Authenticates a parent and returns JWT token.

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "parent@example.com",
  "password": "SecurePassword123"
}
```

**iOS Model:**
```swift
struct LoginParentRequest: Codable {
    let email: String
    let password: String
}
```

**Success Response (200 OK):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "parent": {
    "id": "parent_uuid",
    "email": "parent@example.com",
    "phone": "+1234567890",
    "avatar": "https://example.com/avatar.jpg"
  }
}
```

**iOS Model:**
```swift
struct AuthResponse: Codable {
    let access_token: String
    let token_type: String
    let parent: ParentInfo?
}

struct ParentInfo: Codable {
    let id: String
    let email: String
    let phone: String
    let avatar: String?
}
```

**Error Responses:**
- `400 Bad Request` - Missing credentials
- `401 Unauthorized` - Invalid credentials

**iOS Implementation:**
```swift
authViewModel.loginParent(
    email: "parent@example.com",
    password: "SecurePassword123"
) { success in
    if success {
        // Access token stored in authViewModel.accessToken
        // Navigate to Parent Dashboard
    }
}
```

---

### 3. Login Child

**Endpoint:** `POST /auth/login/child`

**Description:** Authenticates a child using their username and parent's password.

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "username": "johnny",
  "password": "SecurePassword123"
}
```

**iOS Model:**
```swift
struct LoginChildRequest: Codable {
    let username: String
    let password: String
}
```

**Success Response (200 OK):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "child": {
    "id": "child_uuid",
    "username": "johnny",
    "age": 8,
    "gender": "male",
    "avatar": "https://example.com/child-avatar.jpg"
  }
}
```

**iOS Model:**
```swift
struct AuthResponse: Codable {
    let access_token: String
    let token_type: String
    let child: ChildInfo?
}

struct ChildInfo: Codable {
    let id: String
    let username: String
    let age: Int
    let gender: String
    let avatar: String?
}
```

**Error Responses:**
- `400 Bad Request` - Missing credentials
- `401 Unauthorized` - Invalid credentials
- `404 Not Found` - Child not found

**iOS Implementation:**
```swift
authViewModel.loginChild(
    username: "johnny",
    password: "SecurePassword123"
) { success in
    if success {
        // Access token stored in authViewModel.accessToken
        // Navigate to Child Dashboard
    }
}
```

---

## Parent Operations (JWT Protected)

### 4. Add Child

**Endpoint:** `POST /parent/children`

**Description:** Adds a new child to the authenticated parent's account. The child automatically inherits the parent's hashed password.

**Request Headers:**
```
Content-Type: application/json
Authorization: Bearer {access_token}
```

**Request Body:**
```json
{
  "username": "johnny",
  "age": 8,
  "gender": "male"
}
```

**iOS Model:**
```swift
struct AddChildRequest: Codable {
    let username: String
    let age: Int
    let gender: String // "male" or "female"
}
```

**Success Response (201 Created):**
```json
{
  "id": "child_uuid",
  "username": "johnny",
  "age": 8,
  "gender": "male",
  "avatar": "",
  "parent": "parent_uuid"
}
```

**iOS Model:**
```swift
struct ChildResponse: Codable {
    let id: String
    let username: String
    let age: Int
    let gender: String
    let avatar: String?
}
```

**Error Responses:**
- `400 Bad Request` - Validation errors (missing fields, invalid age)
- `401 Unauthorized` - Invalid or missing token
- `409 Conflict` - Username already exists

**Backend Behavior:**
- Child inherits parent's hashed password automatically
- Confirmation email is sent to parent
- Child is added to parent's children array

**iOS Implementation:**
```swift
authViewModel.addChild(
    username: "johnny",
    age: 8,
    gender: "male"
) { success in
    if success {
        // Child added successfully
        // Refresh children list
        authViewModel.fetchChildren()
    }
}
```

---

### 5. Get Children

**Endpoint:** `GET /parent/children`

**Description:** Retrieves all children associated with the authenticated parent.

**Request Headers:**
```
Authorization: Bearer {access_token}
```

**Success Response (200 OK):**
```json
[
  {
    "id": "child_uuid_1",
    "username": "johnny",
    "age": 8,
    "gender": "male",
    "avatar": "https://example.com/avatar1.jpg"
  },
  {
    "id": "child_uuid_2",
    "username": "sarah",
    "age": 6,
    "gender": "female",
    "avatar": "https://example.com/avatar2.jpg"
  }
]
```

**iOS Storage:**
```swift
@Published var childrenList: [[String: Any]] = []
```

**Error Responses:**
- `401 Unauthorized` - Invalid or missing token
- `404 Not Found` - Parent not found

**iOS Implementation:**
```swift
authViewModel.fetchChildren()

// Access the list in SwiftUI:
ForEach(authViewModel.childrenList, id: \.self) { child in
    let username = child["username"] as? String ?? ""
    let age = child["age"] as? Int ?? 0
    let gender = child["gender"] as? String ?? ""
    // Display child information
}
```

---

## Error Handling

### Error Response Format

All error responses follow this structure:

```json
{
  "message": "Error description",
  "statusCode": 400
}
```

**iOS Model:**
```swift
struct ErrorResponse: Codable {
    let message: String
    let statusCode: Int?
}
```

### Common HTTP Status Codes

- `200 OK` - Request successful
- `201 Created` - Resource created successfully
- `400 Bad Request` - Invalid request data
- `401 Unauthorized` - Authentication required or failed
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `409 Conflict` - Resource already exists
- `500 Internal Server Error` - Server error

### iOS Error Handling

```swift
// Network errors
if let error = error {
    errorMessage = "Network error: \(error.localizedDescription)"
    return
}

// HTTP errors
if let httpResponse = response as? HTTPURLResponse {
    if httpResponse.statusCode != 200 {
        if let data = data,
           let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            errorMessage = errorResponse.message
        } else {
            errorMessage = "Request failed with status code: \(httpResponse.statusCode)"
        }
    }
}
```

---

## JWT Token Management

### Token Storage

Tokens are stored in memory during the app session:

```swift
@Published var accessToken: String?
```

### Token Usage

Include the token in the Authorization header for protected endpoints:

```swift
var urlRequest = URLRequest(url: url)
urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
```

### Token Lifecycle

1. **Obtain Token:** Login successful → Store in `accessToken`
2. **Use Token:** Include in Authorization header for protected endpoints
3. **Clear Token:** Logout → Set `accessToken = nil`

### Future Enhancements

- Persist token to Keychain for auto-login
- Implement token refresh mechanism
- Handle token expiration gracefully

---

## Network Configuration

### App Transport Security (ATS)

For local development, ATS is configured to allow HTTP connections:

**Info.plist:**
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

⚠️ **Production Warning:** Remove this setting in production and use HTTPS exclusively.

### Timeout Configuration

Default URLSession timeout values are used. To customize:

```swift
var urlRequest = URLRequest(url: url)
urlRequest.timeoutInterval = 30 // seconds
```

### SSL Pinning (Future)

For production, implement SSL certificate pinning for enhanced security.

---

## Testing the API

### Using cURL

**Register Parent:**
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "parent@test.com",
    "phone": "+1234567890",
    "password": "Test123!",
    "confirmPassword": "Test123!"
  }'
```

**Login Parent:**
```bash
curl -X POST http://localhost:3000/auth/login/parent \
  -H "Content-Type: application/json" \
  -d '{
    "email": "parent@test.com",
    "password": "Test123!"
  }'
```

**Add Child (with token):**
```bash
curl -X POST http://localhost:3000/parent/children \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "username": "johnny",
    "age": 8,
    "gender": "male"
  }'
```

**Get Children (with token):**
```bash
curl -X GET http://localhost:3000/parent/children \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## Backend Requirements

The iOS app expects the backend to implement:

1. **Password Inheritance:** When adding a child, the backend automatically assigns the parent's hashed password to the child
2. **Email Confirmation:** After adding a child, a confirmation email is sent to the parent
3. **JWT Authentication:** All protected endpoints validate JWT tokens
4. **CORS:** Backend must allow requests from the iOS app (during development)

---

## Migration Notes

If updating from a previous version:

1. Ensure backend is on the `backend1` branch
2. Update API base URL if changed
3. Clear any cached data
4. Test all authentication flows
5. Verify JWT token format is compatible

---

## Support

For API-related issues:
1. Check backend logs
2. Verify endpoint URLs match exactly
3. Confirm request/response formats
4. Check JWT token validity
5. Review network console in Xcode

For iOS-specific issues:
1. Check Xcode console for error messages
2. Verify `AuthViewModel` state
3. Confirm network permissions
4. Test with Charles Proxy or similar tool
