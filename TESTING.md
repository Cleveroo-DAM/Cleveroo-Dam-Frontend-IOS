# Cleveroo iOS - Testing Guide

## Prerequisites

1. **Backend Running**: Ensure the NestJS backend is running on `http://localhost:3000`
2. **Xcode**: Open the project in Xcode 14.0 or later
3. **iOS Simulator**: Use iOS 15.0+ simulator or device

## Test Scenarios

### 1. Parent Registration Flow

**Steps:**
1. Launch the app
2. Tap "Sign Up" on the login screen
3. Fill in the registration form:
   - Email: `parent@test.com`
   - Phone: `+1234567890`
   - Password: `Test123!`
   - Confirm Password: `Test123!`
4. Tap "Sign Up"

**Expected Result:**
- Success alert appears
- User is redirected to login screen
- Parent account is created in database with empty children array

**Error Cases to Test:**
- Empty fields → "All fields are required"
- Mismatched passwords → "Passwords do not match"
- Existing email → Backend error message
- Invalid email format → Backend validation error

---

### 2. Parent Login Flow

**Steps:**
1. On login screen, ensure "Parent" tab is selected
2. Enter:
   - Email: `parent@test.com`
   - Password: `Test123!`
3. Tap "Login"

**Expected Result:**
- Loading indicator appears
- User is authenticated
- JWT token is stored
- Navigated to Parent Dashboard
- Empty state shown if no children

**Error Cases to Test:**
- Wrong password → "Login failed"
- Non-existent email → Backend error
- Empty fields → "Email and password are required"
- Network error → "Network error: ..."

---

### 3. Add Child Flow

**Steps:**
1. Login as parent
2. On Parent Dashboard, tap the "+" FAB button
3. Fill in child information:
   - Username: `johnny`
   - Age: `8`
   - Gender: Select "Boy"
4. Tap "Add Child"

**Expected Result:**
- Success alert appears
- User returns to Parent Dashboard
- Children list refreshes automatically
- New child appears in the list with:
  - Avatar (👦 emoji)
  - Username: "johnny"
  - Age: "8 years"
  - Gender: "Male"

**Error Cases to Test:**
- Empty username → "Please enter a username"
- Invalid age (0 or negative) → "Please enter a valid age"
- Non-numeric age → "Please enter a valid age"
- Duplicate username → Backend error

---

### 4. View Children List

**Steps:**
1. Login as parent with existing children
2. Observe the Parent Dashboard

**Expected Result:**
- Loading indicator appears briefly
- GET /parent/children is called with JWT
- All children are displayed in cards
- Each card shows:
  - Gender emoji (👦 for male, 👧 for female)
  - Username
  - Age with calendar icon
  - Gender with figure icon
  - Chevron right indicator

**Edge Cases:**
- No children → Empty state with "No Children Yet" message
- Multiple children → Scrollable list
- Network error → Error message displayed

---

### 5. Child Login Flow

**Steps:**
1. On login screen, select "Child" tab
2. Enter:
   - Username: `johnny`
   - Password: `Test123!` (parent's password)
3. Tap "Login"

**Expected Result:**
- Loading indicator appears
- Child is authenticated
- JWT token is stored
- Navigated to Child Dashboard
- Welcome screen is shown

**Error Cases to Test:**
- Wrong password → "Login failed"
- Non-existent username → Backend error
- Empty fields → "Username and password are required"

---

### 6. Logout Flow

**Steps:**
1. Login as either parent or child
2. On dashboard, tap logout icon (top right)

**Expected Result:**
- User is logged out
- Token is cleared
- Redirected to login screen
- Previous data is cleared

---

### 7. Navigation Flow

**Test all navigation paths:**
- Login → Register → Back to Login
- Login (Parent) → Dashboard → Add Child → Back to Dashboard
- Login (Child) → Child Dashboard
- Any screen → Logout → Login

**Expected:**
- Navigation works smoothly
- No crashes
- Data persists appropriately
- UI state resets properly

---

## API Integration Tests

### Endpoints Verification

1. **POST /auth/register**
   - Request body includes: email, phone, password, confirmPassword
   - Returns 201 on success
   - Creates parent with empty children array

2. **POST /auth/login/parent**
   - Request body: email, password
   - Returns 200 with: access_token, token_type, parent info
   - Token is valid JWT

3. **POST /auth/login/child**
   - Request body: username, password
   - Returns 200 with: access_token, token_type, child info
   - Child uses parent's password

4. **POST /parent/children** (JWT Protected)
   - Headers: Authorization: Bearer {token}
   - Request body: username, age, gender
   - Returns 201 on success
   - Child inherits parent's hashed password
   - Confirmation email is sent (backend)

5. **GET /parent/children** (JWT Protected)
   - Headers: Authorization: Bearer {token}
   - Returns array of children
   - Each child has: id, username, age, gender, avatar

---

## UI/UX Tests

### Design Verification

1. **Color Scheme:**
   - Gradient background: Purple (#9C27B0) to Green (#98FF98)
   - Opacity: 0.9 for purple, 0.6 for green
   - Gradient direction: topLeading to bottomTrailing

2. **Typography:**
   - App title: 48pt, bold
   - Section titles: title/title2
   - Body text: headline/subheadline
   - All text readable on gradient

3. **Components:**
   - Text fields: White background with 0.9 opacity, rounded corners
   - Buttons: 50pt height, 25pt corner radius
   - Cards: White with 0.2 opacity, 15pt corner radius
   - FAB: 60x60 circle, purple background, shadow

4. **Icons:**
   - SF Symbols used consistently
   - Gender emojis: 👦 for boys, 👧 for girls
   - Appropriate icons for age (calendar), gender (figure.child)

---

## Error Handling Tests

1. **Network Errors:**
   - Turn off backend → "Network error" message
   - Slow network → Loading indicator shows
   - Timeout → Appropriate error message

2. **Authentication Errors:**
   - Invalid token → Redirects to login
   - Expired token → Error message
   - Missing token → "Not authenticated"

3. **Validation Errors:**
   - Client-side validation works before API call
   - Server-side errors displayed properly
   - Error messages are user-friendly

---

## Performance Tests

1. **Loading States:**
   - All async operations show loading indicators
   - UI remains responsive during API calls
   - No UI freezing

2. **Data Refresh:**
   - Children list refreshes after adding child
   - Data persists across navigation
   - Memory usage is reasonable

---

## Security Considerations

1. **JWT Storage:**
   - Token stored in memory (not persisted)
   - Token cleared on logout
   - Token included in Authorization header

2. **Password Handling:**
   - Passwords not stored locally
   - SecureField used for password input
   - Passwords only sent over API

3. **Network Security:**
   - HTTPS should be used in production
   - App Transport Security configured for localhost testing
   - No sensitive data in logs

---

## Known Limitations

1. **Token Persistence:**
   - JWT not persisted to Keychain (session only)
   - User must login again after app restart

2. **Avatar Support:**
   - Only emoji avatars currently
   - No image upload functionality yet

3. **Offline Support:**
   - App requires network connection
   - No offline data caching

---

## Future Test Cases

1. Password reset functionality
2. Profile picture upload
3. Edit child information
4. Delete child
5. Biometric authentication
6. Token refresh mechanism
7. Deep linking
8. Push notifications
9. Localization
10. Accessibility features

---

## Bug Reporting Template

When reporting issues, include:

```
**Environment:**
- iOS Version:
- Device/Simulator:
- Backend URL:

**Steps to Reproduce:**
1. 
2. 
3. 

**Expected Behavior:**


**Actual Behavior:**


**Screenshots:**
(if applicable)

**Console Logs:**
(if available)
```

---

## Automated Testing

To add automated tests in the future:

1. **Unit Tests:**
   - Test AuthViewModel methods
   - Test data model encoding/decoding
   - Test validation logic

2. **UI Tests:**
   - Test complete user flows
   - Test navigation
   - Test error states

3. **Integration Tests:**
   - Test API integration with mock server
   - Test token management
   - Test data persistence

---

## Test Checklist

Before marking the feature as complete:

- [ ] All registration scenarios tested
- [ ] All login scenarios tested (parent & child)
- [ ] Add child flow works correctly
- [ ] Children list displays properly
- [ ] Error handling works as expected
- [ ] UI matches design specifications
- [ ] Navigation flows smoothly
- [ ] Logout works correctly
- [ ] No crashes or memory leaks
- [ ] Code follows MVVM pattern
- [ ] API integration tested with real backend
- [ ] Security considerations addressed
