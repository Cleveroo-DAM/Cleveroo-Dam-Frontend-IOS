# Activity Management Integration Guide

## 📦 Files Created

This implementation adds activity management features to the Cleveroo iOS app. The following files have been created:

### Models
- `Cleveroo/Models/Activity.swift` - Activity model
- `Cleveroo/Models/ActivityAssignment.swift` - Activity assignment model with nested ActivityDetails

### ViewModels
- `Cleveroo/ViewModels/ActivityViewModel.swift` - ViewModel for managing activities with API calls

### Parent Views
- `Cleveroo/Views/Parent/AssignActivityView.swift` - View for assigning activities to children

### Child Views
- `Cleveroo/Views/Child/ChildDashboardView.swift` - Dashboard showing child's activities
- `Cleveroo/Views/Child/GameWebView.swift` - WebView for playing external games
- `Cleveroo/Views/Child/CompleteActivityView.swift` - Form for completing activities

### Modified Files
- `Cleveroo/Views/Profile/ChildDetailView.swift` - Added activities section
- `Cleveroo/Views/Home/HomeView.swift` - Added "My Activities" button

## 🔧 Integration Steps

Since the files are not yet added to the Xcode project file, you need to manually add them:

### Step 1: Add Files to Xcode Project

1. Open `Cleveroo.xcodeproj` in Xcode
2. Right-click on the `Models` folder in the Project Navigator
3. Select "Add Files to Cleveroo..."
4. Navigate to and select:
   - `Cleveroo/Models/Activity.swift`
   - `Cleveroo/Models/ActivityAssignment.swift`
5. Ensure "Copy items if needed" is UNCHECKED
6. Ensure "Add to targets: Cleveroo" is CHECKED
7. Click "Add"

### Step 2: Add ViewModels

1. Right-click on the `ViewModels` folder
2. Select "Add Files to Cleveroo..."
3. Navigate to and select:
   - `Cleveroo/ViewModels/ActivityViewModel.swift`
4. Ensure "Copy items if needed" is UNCHECKED
5. Ensure "Add to targets: Cleveroo" is CHECKED
6. Click "Add"

### Step 3: Add Parent Views

1. Right-click on the `Views` folder
2. If the `Parent` subfolder doesn't exist in Xcode, create a new group called "Parent"
3. Right-click on the `Parent` group
4. Select "Add Files to Cleveroo..."
5. Navigate to and select:
   - `Cleveroo/Views/Parent/AssignActivityView.swift`
6. Ensure "Copy items if needed" is UNCHECKED
7. Ensure "Add to targets: Cleveroo" is CHECKED
8. Click "Add"

### Step 4: Add Child Views

1. Right-click on the `Views` folder
2. If the `Child` subfolder doesn't exist in Xcode, create a new group called "Child"
3. Right-click on the `Child` group
4. Select "Add Files to Cleveroo..."
5. Navigate to and select:
   - `Cleveroo/Views/Child/ChildDashboardView.swift`
   - `Cleveroo/Views/Child/GameWebView.swift`
   - `Cleveroo/Views/Child/CompleteActivityView.swift`
6. Ensure "Copy items if needed" is UNCHECKED
7. Ensure "Add to targets: Cleveroo" is CHECKED
8. Click "Add"

### Step 5: Build and Test

1. Build the project (Cmd+B)
2. Fix any compilation errors if they appear
3. Run the app on a simulator or device

## ✅ Features Implemented

### For Parents:
- View list of children
- Click on a child to see their profile and assigned activities
- Assign new activities to children from available activities list
- View activity status (To Do, In Progress, Completed)
- See scores for completed activities

### For Children:
- View dashboard with assigned activities
- Click on activities to play them in a WebView
- Mark activities as completed with score and notes
- See activity status with colored badges

## 🎨 Design Elements

All views follow the existing design patterns:
- `BubbleBackground()` for consistent backgrounds
- Purple/Pink gradient buttons
- Rounded corners (15-20px)
- Status badges with emojis
- Domain-based color coding:
  - Math → Blue
  - Logic → Purple
  - Literature → Orange
  - Sport → Green
  - Language → Pink
  - Creativity → Yellow

## 🔌 API Integration

The app connects to `http://localhost:3000` with the following endpoints:

- `GET /activities` - Fetch all activities (no auth required)
- `POST /activities/assign` - Assign activity to child (requires JWT)
- `GET /activities/child/:childId` - Get child's activities (requires JWT)
- `GET /activities/my` - Get my activities (requires JWT)
- `PATCH /activities/assignments/:id/complete` - Complete activity (requires JWT)

## 🐛 Troubleshooting

### Build Errors
If you encounter build errors:
1. Check that all files are added to the Cleveroo target
2. Clean build folder (Shift+Cmd+K)
3. Rebuild project (Cmd+B)

### Missing Imports
All views use standard SwiftUI and WebKit imports. If you see import errors, make sure:
- iOS deployment target is set correctly
- All SwiftUI frameworks are available

### Navigation Issues
If navigation doesn't work:
1. Check that `NavigationStack` is properly used in parent views
2. Verify `@StateObject` and `@ObservedObject` are used correctly
3. Make sure `dismiss` environment value is available in sheet presentations

## 📱 Testing Checklist

- [ ] Parent can log in and see children list
- [ ] Parent can click on a child to see ChildDetailView
- [ ] Parent can see "Assign" button in activities section
- [ ] Parent can open AssignActivityView and see all activities
- [ ] Parent can assign an activity to a child
- [ ] Child can log in and see HomeView with "My Activities" button
- [ ] Child can navigate to ChildDashboardView
- [ ] Child can see their assigned activities
- [ ] Child can click on an activity to open GameWebView
- [ ] GameWebView loads the external URL
- [ ] Child can mark activity as completed
- [ ] CompleteActivityView shows score slider and notes field
- [ ] Completion updates the activity status

## 🚀 Next Steps

After integration:
1. Connect to a running backend server
2. Test with real data
3. Add error handling for network failures
4. Consider adding pull-to-refresh on activity lists
5. Add activity filtering/sorting options
6. Implement due date selection when assigning activities
