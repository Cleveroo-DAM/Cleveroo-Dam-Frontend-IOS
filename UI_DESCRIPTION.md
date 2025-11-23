# UI Description - Activity Management Views

This document describes the visual appearance of each view implemented for the activity management system.

## 🎨 General Design Elements

All views share these common design elements:
- **Background**: Purple-to-mint gradient with floating white bubble animations
- **Cards**: White semi-transparent backgrounds (0.15-0.2 opacity) with rounded corners (15-20px)
- **Borders**: White semi-transparent strokes (0.3 opacity)
- **Buttons**: Purple-to-pink gradient with rounded corners
- **Text**: White for primary text, white with reduced opacity for secondary text
- **Animations**: Smooth spring animations with staggered delays

## Parent Views

### 1. ParentDashboardView (Modified)
**Description**: Main parent dashboard showing list of children

**Visual Elements**:
- **Header**: "👨‍👩‍👧 Parent Dashboard" title in white
- **Children List**: Scrollable list of child cards
- **Each Child Card**:
  - Large circular avatar with purple-pink gradient background
  - Gender emoji (👦 or 👧) in center
  - Child username in bold white text
  - Age and gender labels below
  - Right chevron icon indicating it's tappable
  - Card has white semi-transparent background with border
  - Smooth fade-in and slide-up animation
- **Floating Action Button**: 
  - Purple-pink gradient circle button in bottom-right
  - Plus icon for adding new child
  - Shadow and glow effect

**Navigation**: Tapping a child card navigates to ChildDetailView

---

### 2. ChildDetailView (Updated)
**Description**: Detailed view of a child's profile and activities

**Visual Elements**:

**Profile Section**:
- Large circular avatar (120x120) with purple-pink gradient
- Gender emoji (70pt size)
- Child's username in large bold white text
- Age and gender info with icons

**Account Info Card**:
- Blue info icon with "Account Information" header
- Rows showing username, age, gender, member since
- Each row with cyan icon and white text
- Semi-transparent white background card

**Assigned Activities Section** (NEW):
- Orange gamecontroller icon with "Assigned Activities" header
- "Assign" button (purple-pink gradient, rounded pill shape) on right
- If empty: Gray tray icon with "No activities assigned yet" message
- If activities exist: List of ActivityAssignmentCards (see below)
- Loading state shows white spinner

**ActivityAssignmentCard**:
- Horizontal layout with circular icon on left
- Icon color matches activity domain (blue for math, purple for logic, etc.)
- Activity title in bold white
- Description in smaller white text (if available)
- Status badge below (see StatusBadge)
- Due date with calendar icon (if available)
- Score with star icon (if completed)
- White semi-transparent background with rounded corners

**StatusBadge**:
- Small rounded pill with emoji and text
- Orange for "📋 To Do" (assigned)
- Blue for "🎮 In Progress" (in_progress)
- Green for "✅ Completed" (completed)

**Other Sections**: Progress Overview and Quick Stats (unchanged)

**Navigation**: 
- Tapping "Assign" opens AssignActivityView sheet
- Scrollable content with smooth animations

---

### 3. AssignActivityView (New)
**Description**: Sheet modal for assigning activities to a child

**Visual Elements**:

**Header**:
- "🎯 Assign Activity" title in white
- "Choose an activity to assign" subtitle

**Activities List**:
- Scrollable list of ActivitySelectionCards
- Loading state: White spinner in center
- Empty state: Gray tray icon with "No activities available" message

**ActivitySelectionCard**:
- Large circular icon (60x60) with activity type icon
- Icon color matches domain (blue for math, purple for logic, etc.)
- Activity title in bold white (headline font)
- Description in smaller white text below
- Metadata row with:
  - Type tag (e.g., "External_game") with tag icon
  - Domain label with folder icon (colored by domain)
  - Age range (e.g., "6-12 yrs") with cake icon
- "Assign" button at bottom:
  - Purple-pink gradient
  - Plus circle icon with "Assign" text
  - Full width of card
- White semi-transparent background with border
- Shadow for depth

**Toolbar**:
- "Cancel" button on left in navigation bar

**Interactions**:
- Tapping "Assign" on a card shows confirmation alert
- Alert: "Are you sure you want to assign '[Activity Title]' to this child?"
- Confirming shows success alert or error alert
- Success dismisses sheet and refreshes parent view

---

## Child Views

### 4. ChildDashboardView (New)
**Description**: Main dashboard for children showing their assigned activities

**Visual Elements**:

**Header**:
- "🎮 My Activities" title in large white bold text
- "Play and complete your activities" subtitle

**Activities List**:
- Loading state: White spinner in center
- Empty state: 
  - Large gray tray icon (80pt)
  - "No activities yet" message
  - "Your parent will assign activities for you" subtitle
- If activities exist: List of ChildActivityCards (see below)

**ChildActivityCard**:
- Large circular icon (70x70) with activity type icon
- Icon with domain-colored background
- Activity title in bold white
- Description in smaller white text (if available)
- Bottom row with:
  - Status badge (see StatusBadge)
  - "Play Now" indicator with play icon (if not completed, cyan color)
  - Score display with star icon (if completed, yellow)
- Right chevron indicating it's tappable
- White semi-transparent background
- Border colored by domain with 2px width
- Domain-colored shadow for glow effect
- Cards fade in with staggered animation

**Navigation**: Tapping a card opens GameWebView sheet

---

### 5. GameWebView (New)
**Description**: Full-screen WebView for playing external games

**Visual Elements**:

**Navigation Bar**:
- Activity title displayed
- Close button (X icon) on left

**WebView**:
- Full screen WKWebView loading external game URL
- White loading spinner shown while loading

**Floating Button** (if not completed):
- Green-to-cyan gradient rounded pill button
- Positioned at bottom center
- Checkmark circle icon with "Mark as Completed" text
- Green shadow for glow effect
- Floats above WebView content

**Interactions**:
- WebView is interactive (can play game)
- Tapping close dismisses view
- Tapping "Mark as Completed" opens CompleteActivityView sheet

---

### 6. CompleteActivityView (New)
**Description**: Form for marking an activity as completed with score and notes

**Visual Elements**:

**Header**:
- Large green checkmark seal icon (70pt) with green glow
- "Complete Activity" title in white
- "How did you do?" subtitle

**Score Section**:
- Yellow star icon with "Your Score" header
- Large score display (e.g., "75%") in center (48pt bold)
- Horizontal slider below (0-100%, step by 5)
- Yellow accent color for slider
- "0%" and "100%" labels at ends
- White semi-transparent card background

**Notes Section**:
- Cyan note icon with "Notes (Optional)" header
- Multi-line text editor (120pt height)
- White-on-semi-transparent background
- Placeholder visible
- Helper text: "Share your thoughts or what you learned"
- White semi-transparent card background

**Submit Button**:
- Large green-to-cyan gradient button
- Checkmark circle icon with "Submit Completion" text
- Full width with rounded corners
- Green shadow for glow
- Shows white spinner when loading

**Cancel Button**:
- Simple text button below submit
- White semi-transparent text

**Interactions**:
- Score slider updates the displayed percentage
- Text editor for free-form notes
- Tapping submit calls API and shows success/error alert
- Success alert: "Success! 🎉" with "Activity completed successfully!"
- Success dismisses both sheets and refreshes dashboard

---

## Updated Existing Views

### 7. HomeView (Updated)
**Description**: Child's home screen

**Added Element**:
- New "My Activities" button at top of action buttons list
- Green-to-cyan gradient (different from other buttons)
- 🎯 emoji icon
- "My Activities" text
- Full-width capsule shape with shadow
- Tapping navigates to ChildDashboardView

**Existing Elements**: Welcome message, progress bar, other game buttons (unchanged)

---

## Color Scheme

### Domain Colors
Activities are color-coded by domain:
- 🔵 **Math**: Blue
- 🟣 **Logic**: Purple  
- 🟠 **Literature**: Orange
- 🟢 **Sport**: Green
- 🌸 **Language**: Pink
- 🟡 **Creativity**: Yellow
- 🔷 **Default**: Cyan

### Status Colors
Activity status is color-coded:
- 🟠 **Assigned** ("To Do"): Orange
- 🔵 **In Progress**: Blue
- 🟢 **Completed**: Green

### UI Element Colors
- **Primary Actions**: Purple-to-pink gradient
- **Success Actions**: Green-to-cyan gradient
- **Backgrounds**: White with 15-20% opacity
- **Borders**: White with 30% opacity
- **Text Primary**: White 100%
- **Text Secondary**: White 60-80%

## Animations

### Entry Animations
- Fade in with opacity 0 → 1
- Slide up with offset 20 → 0
- Spring animation (0.6s response, 0.7 damping)
- Staggered delays (0.1s per item)

### Interaction Animations
- Button scale on tap (1.0 → 1.05)
- Spring response for natural feel
- Smooth transitions between views

### Loading States
- Circular progress spinner in white
- Centered vertically and horizontally
- Scale 1.5x for visibility

## Accessibility

All views use:
- Semantic SF Symbols icons
- Clear text hierarchy (title > headline > subheadline > caption)
- High contrast text (white on colored backgrounds)
- Touch targets minimum 44pt
- Labels for screen readers
- System font scaling support

## Responsive Design

- ScrollViews for content longer than screen
- Cards adapt to device width with padding
- Stack layouts for vertical arrangement
- HStack for horizontal elements
- LazyVGrid for grids (if needed)
- Safe area respected with padding

---

## Example User Flows

### Parent Assigns Activity
1. ParentDashboardView → Tap child card
2. ChildDetailView appears with slide animation
3. Activities section shows "No activities assigned yet"
4. Tap "Assign" button → Sheet slides up
5. AssignActivityView shows with fade-in
6. Scroll through activities, tap "Assign" on one
7. Confirmation alert appears
8. Tap "Assign" in alert
9. Success alert appears
10. Tap "OK" → Sheet dismisses
11. ChildDetailView refreshes, shows new activity with "To Do" badge

### Child Completes Activity
1. HomeView → Tap "My Activities"
2. ChildDashboardView appears
3. Activity cards fade in with stagger
4. Tap an activity card → Sheet slides up
5. GameWebView appears, loads game
6. Play game in WebView
7. Tap "Mark as Completed" button
8. CompleteActivityView sheet appears
9. Adjust score slider (live percentage update)
10. Type notes in text editor
11. Tap "Submit Completion" → Button shows spinner
12. Success alert appears
13. Tap "OK" → Both sheets dismiss
14. ChildDashboardView refreshes, badge changes to green "Completed"

---

This UI provides a cohesive, engaging experience for both parents and children while maintaining consistency with the existing Cleveroo app design language.
