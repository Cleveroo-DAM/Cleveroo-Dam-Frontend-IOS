//
//  ChildDetailView.swift
//  Cleveroo
//
//  Detailed view of a child's profile and progress
//

import SwiftUI

struct ChildDetailView: View {
    let child: [String: Any]
    @StateObject private var activityVM = ActivityViewModel()
    @StateObject private var reportViewModel = AIReportViewModel()
    @State private var showContent = false
    @State private var showAssignActivity = false
    @State private var qrToken: String?
    @State private var qrImage: UIImage?
    @State private var isLoadingQR = false
    @State private var showScoresHistory = false
    @ObservedObject var authVM = AuthViewModel()
    
    var body: some View {
        ZStack {
            BubbleBackground().ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // ...existing code...
                    // Child Profile Header
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple, Color.pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Text(genderEmoji)
                                .font(.system(size: 70))
                        }
                        .shadow(color: .white.opacity(0.5), radius: 10)
                        
                        VStack(spacing: 8) {
                            Text(username)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 15) {
                                Label("\(age) years old", systemImage: "birthday.cake")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text("•")
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Text(gender.capitalized)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                    .padding(.top, 30)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : -20)
                    
                    // Account Info Card
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.cyan)
                            Text("Account Information")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        InfoRow(icon: "person.circle", label: "Username", value: username)
                        InfoRow(icon: "number.circle", label: "Age", value: "\(age) years")
                        InfoRow(icon: "person.fill", label: "Gender", value: gender.capitalized)
                        
                        if let createdAt = child["createdAt"] as? String {
                            InfoRow(icon: "calendar", label: "Member Since", value: formatDate(createdAt))
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: showContent)
                    
                    // Activities Section
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "gamecontroller.fill")
                                .foregroundColor(.orange)
                            Text("Assigned Activities")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Button(action: {
                                    showScoresHistory = true
                                }) {
                                    HStack(spacing: 5) {
                                        Image(systemName: "chart.bar.fill")
                                        //Text("History")
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.blue, Color.cyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(20)
                                }
                                
                                Button(action: {
                                    showAssignActivity = true
                                }) {
                                    HStack(spacing: 5) {
                                        Image(systemName: "plus.circle.fill")
                                        //Text("Assign")
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.purple, Color.pink],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(20)
                                }
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        if activityVM.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Spacer()
                            }
                            .padding()
                        } else if activityVM.childAssignments.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "tray")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.5))
                                Text("No activities assigned yet")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                Text("Tap 'Assign' to add an activity")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        } else {
                            VStack(spacing: 12) {
                                ForEach(activityVM.childAssignments) { assignment in
                                    ActivityAssignmentCard(assignment: assignment)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.15), value: showContent)
                    
                    // Progress Overview
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.green)
                            Text("Learning Progress")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        // Memory Games Progress
                        ProgressSection(
                            title: "Memory Games",
                            icon: "brain.head.profile",
                            progress: 0.75,
                            stats: [
                                ("Games Played", "12"),
                                ("Best Score", "100%"),
                                ("Avg Time", "45s")
                            ]
                        )
                        
                        // Learning Activities Progress
                        ProgressSection(
                            title: "Learning Activities",
                            icon: "book.fill",
                            progress: 0.60,
                            stats: [
                                ("Completed", "8"),
                                ("In Progress", "3"),
                                ("Total Time", "2h 15m")
                            ]
                        )
                        
                        // AI Reports Progress
                        ProgressSection(
                            title: "AI Reports Generated",
                            icon: "sparkles",
                            progress: 0.40,
                            stats: [
                                ("Total Reports", "5"),
                                ("Latest", "2 days ago"),
                                ("Avg Rating", "⭐️⭐️⭐️⭐️")
                            ]
                        )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showContent)
                    
                    // Quick Stats Grid
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Quick Stats")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            QuickStatCard(icon: "flame.fill", value: "7", label: "Day Streak", color: .orange)
                            QuickStatCard(icon: "trophy.fill", value: "24", label: "Achievements", color: .yellow)
                            QuickStatCard(icon: "clock.fill", value: "5h 30m", label: "Total Time", color: .blue)
                            QuickStatCard(icon: "target", value: "85%", label: "Accuracy", color: .green)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: showContent)
                    
                    // QR Code Section
                    VStack(alignment: .center, spacing: 15) {
                        HStack {
                            Image(systemName: "qrcode")
                                .foregroundColor(.cyan)
                            Text("Login QR Code")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if isLoadingQR {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(width: 20, height: 20)
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        // Display QR Code Image
                        if let qrImage = qrImage {
                            HStack {
                                Spacer()
                                Image(uiImage: qrImage)
                                    .resizable()
                                    .interpolation(.none)
                                    .scaledToFit()
                                    .frame(width: 250, height: 250)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(15)
                                    .shadow(color: Color.black.opacity(0.2), radius: 10)
                                Spacer()
                            }
                        } else {
                            HStack {
                                Spacer()
                                VStack(spacing: 10) {
                                    Image(systemName: "qrcode")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white.opacity(0.5))
                                    
                                    Text("QR Code not available")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .frame(width: 250, height: 250)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(15)
                                Spacer()
                            }
                        }
                        
                        // Display QR Token (if available)
                        if let qrToken = qrToken {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Token")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text(qrToken.prefix(20) + "...")
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                                    .lineLimit(1)
                            }
                        }
                        
                        Text("Share this QR code with your child to login")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.12), value: showContent)
                    
                    Spacer(minLength: 30)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Child Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                showContent = true
            }
            if let childId = child["_id"] as? String ?? child["id"] as? String {
                activityVM.fetchActivitiesForChild(childId: childId)
                loadQRToken(for: childId)
            }
        }
        .sheet(isPresented: $showAssignActivity) {
            if let childId = child["_id"] as? String ?? child["id"] as? String {
                AssignActivityView(childId: childId, activityVM: activityVM) {
                    activityVM.fetchActivitiesForChild(childId: childId)
                }
            }
        }
        .sheet(isPresented: $showScoresHistory) {
            if let childId = child["_id"] as? String ?? child["id"] as? String,
               let childName = child["username"] as? String {
                ActivityScoresHistoryView(
                    childId: childId,
                    childName: childName,
                    activityVM: activityVM
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                let childId = child["_id"] as? String ?? ""
                let username = child["username"] as? String ?? "Unknown"
                
                NavigationLink(destination: ChildReportView(
                    child: Child(id: childId, username: username, age: child["age"] as? Int ?? 0),
                    token: authVM.currentUserToken ?? ""
                )) {
                    HStack(spacing: 6) {
                        Image(systemName: "chart.bar.doc.horizontal.fill")
                        Text("Reports")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var username: String {
        child["username"] as? String ?? "Unknown"
    }
    
    private var age: Int {
        child["age"] as? Int ?? 0
    }
    
    private var gender: String {
        child["gender"] as? String ?? "male"
    }
    
    private var genderEmoji: String {
        let g = gender.lowercased()
        if g.contains("girl") || g == "female" {
            return "👧"
        } else {
            return "👦"
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return dateString
    }
    
    private func loadQRToken(for childId: String) {
        print("🔄 Loading QR token for child: \(childId)")
        isLoadingQR = true
        
        authVM.generateQRTokenForChild(childId: childId) { token, dataUri, error in
            DispatchQueue.main.async {
                self.isLoadingQR = false
                
                if let token = token {
                    print("✅ QR token loaded: \(token.prefix(20))...")
                    self.qrToken = token
                    
                    // Générer l'image QR à partir du token
                    if let qrCodeBase64 = QRCodeService.shared.generateQRCode(from: token) {
                        if let imageData = Data(base64Encoded: qrCodeBase64),
                           let uiImage = UIImage(data: imageData) {
                            self.qrImage = uiImage
                            print("✅ QR image generated successfully")
                        }
                    }
                    
                    // Sinon, utiliser le dataUri du backend s'il existe
                    if self.qrImage == nil, let dataUri = dataUri {
                        if let image = QRCodeService.shared.uiImageFromDataURI(dataUri) {
                            self.qrImage = image
                            print("✅ QR image loaded from backend")
                        }
                    }
                } else {
                    print("❌ Failed to load QR token: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .frame(width: 30)
            
            Text(label)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 120, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}

// MARK: - Progress Section
struct ProgressSection: View {
    let title: String
    let icon: String
    let progress: Double
    let stats: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.cyan)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color.cyan, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
            
            // Stats
            HStack(spacing: 15) {
                ForEach(stats, id: \.0) { stat in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stat.0)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                        Text(stat.1)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Quick Stat Card
struct QuickStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Activity Assignment Card
struct ActivityAssignmentCard: View {
    let assignment: ActivityAssignment
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: activityIcon)
                .font(.system(size: 28))
                .foregroundColor(domainColor)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(domainColor.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(assignment.activityId.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if let description = assignment.activityId.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
                
                HStack(spacing: 10) {
                    StatusBadge(status: assignment.status)
                    
                    if let dueDate = assignment.dueDate {
                        Label(formatDueDate(dueDate), systemImage: "calendar")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    if let score = assignment.score {
                        Label("\(score)%", systemImage: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var activityIcon: String {
        switch assignment.activityId.type.lowercased() {
        case "external_game":
            return "gamecontroller.fill"
        case "quiz":
            return "questionmark.circle.fill"
        default:
            return "book.fill"
        }
    }
    
    private var domainColor: Color {
        switch assignment.activityId.domain.lowercased() {
        case "math":
            return .blue
        case "logic":
            return .purple
        case "literature":
            return .orange
        case "sport":
            return .green
        case "language":
            return .pink
        case "creativity":
            return .yellow
        default:
            return .cyan
        }
    }
    
    private func formatDueDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(statusEmoji)
            Text(statusText)
        }
        .font(.caption2)
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor)
        .cornerRadius(8)
    }
    
    private var statusEmoji: String {
        switch status.lowercased() {
        case "assigned":
            return "📋"
        case "in_progress":
            return "🎮"
        case "completed":
            return "✅"
        default:
            return "📋"
        }
    }
    
    private var statusText: String {
        switch status.lowercased() {
        case "assigned":
            return "To Do"
        case "in_progress":
            return "In Progress"
        case "completed":
            return "Completed"
        default:
            return status.capitalized
        }
    }
    
    private var statusColor: Color {
        switch status.lowercased() {
        case "assigned":
            return .orange
        case "in_progress":
            return .blue
        case "completed":
            return .green
        default:
            return .gray
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ChildDetailView(child: [
            "_id": "123",
            "username": "TestChild",
            "age": 8,
            "gender": "boy",
            "createdAt": "2025-11-16T15:37:26.134Z"
        ])
    }
}
