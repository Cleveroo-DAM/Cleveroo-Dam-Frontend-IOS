# Cleveroo iOS - Quick Start Guide

Get the Cleveroo iOS app up and running in minutes!

## Prerequisites

Before you begin, ensure you have:

- ✅ **macOS** with latest updates
- ✅ **Xcode 14.0+** installed from Mac App Store
- ✅ **iOS Simulator** or physical iOS device (iOS 15.0+)
- ✅ **Backend server** running on your machine or accessible via network

## Step 1: Get the Backend Running

The iOS app requires the Cleveroo backend to be running.

### Option A: Backend on Same Machine

1. Clone and start the backend:
```bash
# In a separate terminal
git clone [backend-repo-url]
cd [backend-directory]
git checkout backend1  # Important: Use backend1 branch
npm install
npm run start:dev
```

2. Verify backend is running:
```bash
curl http://localhost:3000/health
# Should return 200 OK
```

### Option B: Backend on Different Machine

1. Start the backend on the host machine
2. Find your host machine's IP address:
```bash
# macOS/Linux
ifconfig | grep "inet "
# Look for something like: 192.168.1.XXX
```

3. Update the base URL in `AuthViewModel.swift`:
```swift
private let baseURL = "http://192.168.1.XXX:3000"
```

## Step 2: Open the Project in Xcode

1. **Clone the iOS repository:**
```bash
git clone https://github.com/Cleveroo-DAM/Cleveroo-Dam-Frontend-IOS.git
cd Cleveroo-Dam-Frontend-IOS
```

2. **Open the project:**
```bash
open Cleveroo.xcodeproj
```

Or:
- Double-click `Cleveroo.xcodeproj` in Finder
- Or launch Xcode and choose "Open a project or file"

## Step 3: Configure the Project

### Select Your Target Device

1. In Xcode, look at the top toolbar
2. Click on the device selector (next to the play button)
3. Choose either:
   - **iOS Simulator** (e.g., iPhone 14 Pro)
   - **Your physical device** (if connected via USB)

### Verify Build Settings (Optional)

1. Click on the project name in the left sidebar
2. Select the "Cleveroo" target
3. Go to "Signing & Capabilities" tab
4. For development:
   - Keep "Automatically manage signing" checked
   - Select your team (if you have one)
   - Or use "Sign to Run Locally" for simulator only

## Step 4: Build and Run

1. **Click the Play button** (▶️) in Xcode, or press `Cmd + R`

2. **Wait for build to complete** (~30 seconds first time)

3. **App launches** in simulator or on device

## Step 5: Test the App

### Test Parent Registration

1. On the login screen, tap **"Sign Up"**
2. Fill in the form:
   - Email: `parent@test.com`
   - Phone: `+1234567890`
   - Password: `Test123!`
   - Confirm Password: `Test123!`
3. Tap **"Sign Up"**
4. You should see a success message

### Test Parent Login

1. Go back to login screen
2. Select **"Parent"** tab
3. Enter:
   - Email: `parent@test.com`
   - Password: `Test123!`
4. Tap **"Login"**
5. You should see the Parent Dashboard (empty state)

### Test Add Child

1. On Parent Dashboard, tap the **purple "+" button** (bottom right)
2. Fill in child information:
   - Username: `johnny`
   - Age: `8`
   - Gender: **Boy**
3. Tap **"Add Child"**
4. Success message appears
5. You're back at dashboard, child appears in the list

### Test Child Login

1. Logout from parent account (top right icon)
2. Select **"Child"** tab
3. Enter:
   - Username: `johnny`
   - Password: `Test123!` (same as parent's)
4. Tap **"Login"**
5. You should see the Child Dashboard

## Common Issues & Solutions

### Issue: "Cannot connect to backend"

**Solutions:**
1. Verify backend is running: `curl http://localhost:3000`
2. Check firewall settings
3. For physical device: Use IP address instead of localhost
4. Check Xcode console for detailed error messages

### Issue: Build fails with signing errors

**Solutions:**
1. Go to Project Settings → Signing & Capabilities
2. Change Bundle Identifier to something unique (e.g., add your initials)
3. Or run only on Simulator (no signing needed)

### Issue: SwiftUI preview not working

**Solutions:**
1. This is normal for networking code
2. Run the app instead of using preview
3. Or create mock data for preview

### Issue: "No such module SwiftUI"

**Solutions:**
1. Make sure you're opening `.xcodeproj` not individual `.swift` files
2. Restart Xcode
3. Clean build folder: Product → Clean Build Folder (Cmd + Shift + K)

### Issue: Keyboard covers text fields

**Solutions:**
1. This is expected behavior
2. Tap outside keyboard to dismiss it
3. Or swipe down on keyboard

## Development Workflow

### Making Code Changes

1. Edit files in Xcode
2. Build and run (Cmd + R) to test
3. Check Xcode console for logs
4. Use breakpoints for debugging

### Viewing Network Requests

1. Check Xcode console for print statements
2. Or use Charles Proxy or Proxyman to monitor network traffic

### Hot Reload

SwiftUI supports hot reload for UI changes:
1. Make UI changes
2. Save file (Cmd + S)
3. Canvas preview updates automatically (if working)

### Testing on Physical Device

1. Connect iPhone/iPad via USB
2. Select it from device menu
3. Trust the computer on your device
4. Wait for device preparation
5. Run the app

**Backend Access:**
- Device must be on same WiFi network as backend
- Update baseURL to use host machine's IP address

## Next Steps

### Learn the Codebase

1. Read `README.md` for project overview
2. Read `ARCHITECTURE.md` for detailed architecture
3. Read `API_DOCUMENTATION.md` for API details
4. Check `TESTING.md` for test scenarios

### Extend the App

Some ideas:
- Add profile pictures
- Implement edit child functionality
- Add more child dashboard features
- Improve error messages
- Add animations
- Implement dark mode

### Contribute

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## Useful Xcode Shortcuts

- `Cmd + R` - Build and Run
- `Cmd + .` - Stop Running
- `Cmd + B` - Build
- `Cmd + Shift + K` - Clean Build Folder
- `Cmd + K` - Clear Console
- `Cmd + /` - Comment/Uncomment
- `Cmd + Shift + O` - Quick Open File
- `Cmd + Shift + F` - Find in Project
- `Cmd + Option + [` - Move Line Up
- `Cmd + Option + ]` - Move Line Down

## Debugging Tips

### View Logs

Console is at the bottom of Xcode:
- `View → Debug Area → Show Debug Area` (Cmd + Shift + Y)
- Look for error messages and network responses

### Add Print Statements

```swift
print("✅ Login successful, token: \(token)")
print("❌ Error occurred: \(error.localizedDescription)")
```

### Use Breakpoints

1. Click on line number to add breakpoint
2. Run app in debug mode
3. Execution pauses at breakpoint
4. Inspect variables in Variables View
5. Step through code with controls

### Check Network Requests

Add this to see raw responses:
```swift
if let data = data, let responseString = String(data: data, encoding: .utf8) {
    print("📡 Response: \(responseString)")
}
```

## Performance Tips

### Improve Build Speed

1. Close other apps
2. Clean build folder occasionally
3. Restart Xcode if it becomes slow
4. Disable automatic preview if not using it

### Simulator Performance

1. Close unused simulators
2. Use iPhone models (faster than iPad)
3. Reduce simulator scale: Window → Physical Size
4. Restart simulator if laggy

## Additional Resources

- **Xcode Help:** Help → Xcode Help (in menu bar)
- **Swift Docs:** https://swift.org/documentation/
- **SwiftUI Tutorials:** https://developer.apple.com/tutorials/swiftui
- **iOS Development:** https://developer.apple.com/ios/

## Support

If you encounter issues:

1. Check the error message in Xcode console
2. Review the documentation files
3. Search for the error online
4. Ask team members
5. Create an issue on GitHub

## Quick Reference Card

```
┌────────────────────────────────────────────┐
│         CLEVEROO IOS QUICK REF            │
├────────────────────────────────────────────┤
│ Backend URL: http://localhost:3000        │
│ Min iOS: 15.0                             │
│ Language: Swift 5.7+                      │
│ UI Framework: SwiftUI                     │
│ Architecture: MVVM                        │
│                                           │
│ Test Credentials:                         │
│ Parent Email: parent@test.com             │
│ Password: Test123!                        │
│ Child Username: johnny                    │
│ Child Password: Test123! (inherited)      │
│                                           │
│ Key Files:                                │
│ • AuthViewModel.swift - Business logic    │
│ • LoginView.swift - Login UI              │
│ • ParentDashboardView.swift - Main UI     │
│ • AuthModels.swift - Data models          │
└────────────────────────────────────────────┘
```

---

**Ready to code? Let's build something amazing! 🚀**
