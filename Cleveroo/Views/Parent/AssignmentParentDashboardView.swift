//
//  AssignmentParentDashboardView.swift
//  Cleveroo
//
//  Created by GitHub Copilot on 24/11/2025.
//

import SwiftUI

struct AssignmentParentDashboardView: View {
    @StateObject private var viewModel = AssignmentParentViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showCreateAssignment = false
    @State private var selectedAssignment: Assignment?
    @State private var showAssignmentDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background dégradé
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.6),
                        Color.purple.opacity(0.4),
                        Color.pink.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header section
                        headerSection
                        
                        // Statistics section
                        statisticsSection
                        
                        // Soumissions à valider section (priorité)
                        if !submissionsToValidate.isEmpty {
                            submissionsToValidateSection
                        }
                        
                        // Assignments list
                        assignmentsListSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Mes Assignments")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreateAssignment = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }
            .onAppear {
                setupToken()
                viewModel.loadMyAssignments()
            }
            .sheet(isPresented: $showCreateAssignment) {
                CreateAssignmentView(viewModel: viewModel)
                    .environmentObject(authViewModel)
            }
            .sheet(item: $selectedAssignment) { assignment in
                AssignmentDetailView(assignment: assignment, viewModel: viewModel)
            }
            .alert("Erreur", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearMessages()
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .alert("Succès", isPresented: .constant(viewModel.successMessage != nil)) {
                Button("OK") {
                    viewModel.clearMessages()
                }
            } message: {
                if let success = viewModel.successMessage {
                    Text(success)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.clipboard.fill")
                .font(.system(size: 50))
                .foregroundColor(.white)
            
            Text("Gestion des Assignments")
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)
            
            Text("Créez et suivez les tâches de vos enfants")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2))
        )
    }
    
    private var statisticsSection: some View {
        HStack(spacing: 15) {
            AssignmentStatCard(title: "Total", value: "\(viewModel.assignments.count)", color: .blue)
            AssignmentStatCard(title: "En attente", value: "\(pendingCount)", color: .orange)
            AssignmentStatCard(title: "Terminés", value: "\(completedCount)", color: .green)
        }
    }
    
    private var assignmentsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Assignments récents")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button("Actualiser") {
                    viewModel.loadMyAssignments()
                }
                .foregroundColor(.white.opacity(0.8))
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .foregroundColor(.white)
            } else if viewModel.assignments.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("Aucun assignment créé")
                        .font(.title3)
                        .foregroundColor(.white)
                    
                    Text("Appuyez sur + pour créer votre premier assignment")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
                .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.assignments) { assignment in
                        AssignmentCardView(assignment: assignment) {
                            selectedAssignment = assignment
                        }
                    }
                }
            }
        }
    }
    
    private var submissionsToValidateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.orange)
                Text("Soumissions à valider")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(submissionsToValidate.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(submissionsToValidate) { assignment in
                        SubmissionValidationCard(assignment: assignment, viewModel: viewModel) {
                            selectedAssignment = assignment
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.2))
                .stroke(Color.orange.opacity(0.4), lineWidth: 1)
        )
    }
    
    private var submissionsToValidate: [Assignment] {
        viewModel.assignments.filter { $0.status == .submitted }
    }
    
    private var pendingCount: Int {
        viewModel.assignments.filter { $0.status == .assigned || $0.status == .inProgress || $0.status == .submitted }.count
    }
    
    private var completedCount: Int {
        viewModel.assignments.filter { $0.status == .approved }.count
    }
    
    private func setupToken() {
        let token = authViewModel.currentUserToken ?? UserDefaults.standard.string(forKey: "jwt") ?? ""
        viewModel.setParentToken(token)
    }
}

struct AssignmentStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.6), lineWidth: 1)
                )
        )
    }
}

struct AssignmentCardView: View {
    let assignment: Assignment
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                // Type icon
                VStack {
                    Image(systemName: assignment.type.icon)
                        .font(.title2)
                        .foregroundColor(statusColor)
                    
                    Text(assignment.type.displayName)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(width: 60)
                
                // Assignment info
                VStack(alignment: .leading, spacing: 4) {
                    Text(assignment.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    if let description = assignment.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                    
                    HStack {
                        AssignmentStatusBadge(status: assignment.status)
                        
                        Spacer()
                        
                        if let points = assignment.rewardPoints {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("\(points)")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .font(.caption)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var statusColor: Color {
        switch assignment.status {
        case .assigned: return .blue
        case .inProgress: return .orange
        case .submitted: return .purple
        case .approved: return .green
        case .rejected: return .red
        }
    }
}

struct AssignmentStatusBadge: View {
    let status: AssignmentStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
            )
            .foregroundColor(.white)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .assigned: return .blue
        case .inProgress: return .orange
        case .submitted: return .purple
        case .approved: return .green
        case .rejected: return .red
        }
    }
}

struct SubmissionValidationCard: View {
    let assignment: Assignment
    let viewModel: AssignmentParentViewModel
    let onTap: () -> Void
    @State private var showingApprovalAlert = false
    @State private var showingRejectionAlert = false
    @State private var feedbackText = ""
    
    var body: some View {
        VStack(spacing: 12) {
            // Header avec info assignment
            VStack(spacing: 4) {
                Text(assignment.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text("Par: \(childName)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                if let submittedDate = assignment.submittedAt {
                    Text("Soumis le \(DateFormatter.shortDateTime.string(from: submittedDate))")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Photo preview (première photo s'il y en a)
            if !assignment.submissionPhotos.isEmpty {
                AsyncImage(url: URL(string: assignment.submissionPhotos.first ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white.opacity(0.6))
                        )
                }
                .frame(width: 120, height: 80)
                .cornerRadius(8)
                .onTapGesture {
                    onTap() // Ouvrir les détails pour voir toutes les photos
                }
            }
            
            // Commentaire de l'enfant s'il y en a un
            if let comment = assignment.submissionComment, !comment.isEmpty {
                Text("\"\(comment)\"")
                    .font(.caption)
                    .italic()
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
                    .padding(.horizontal, 8)
            }
            
            // Boutons de validation rapide
            HStack(spacing: 8) {
                Button(action: {
                    showingApprovalAlert = true
                }) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Valider")
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green)
                .cornerRadius(16)
                
                Button(action: {
                    showingRejectionAlert = true
                }) {
                    Image(systemName: "xmark.circle.fill")
                    Text("Rejeter")
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red)
                .cornerRadius(16)
            }
            
            // Bouton pour voir les détails
            Button("Voir détails") {
                onTap()
            }
            .font(.caption)
            .foregroundColor(.orange)
        }
        .padding()
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
                .stroke(Color.orange.opacity(0.6), lineWidth: 1)
        )
        .alert("Approuver l'assignment", isPresented: $showingApprovalAlert) {
            TextField("Commentaire (optionnel)", text: $feedbackText)
            Button("Approuver") {
                viewModel.approveSubmission(assignmentId: assignment.id, feedback: feedbackText.isEmpty ? nil : feedbackText)
                feedbackText = ""
            }
            Button("Annuler", role: .cancel) {
                feedbackText = ""
            }
        } message: {
            Text("Voulez-vous approuver cette soumission de \(childName) ?")
        }
        .alert("Rejeter l'assignment", isPresented: $showingRejectionAlert) {
            TextField("Raison du rejet", text: $feedbackText)
            Button("Rejeter") {
                viewModel.rejectSubmission(assignmentId: assignment.id, feedback: feedbackText.isEmpty ? "À refaire" : feedbackText)
                feedbackText = ""
            }
            Button("Annuler", role: .cancel) {
                feedbackText = ""
            }
        } message: {
            Text("Voulez-vous rejeter cette soumission de \(childName) ?")
        }
    }
    
    private var childName: String {
        // Pour l'instant on affiche "Enfant" mais on pourrait récupérer le vrai nom depuis l'API
        return "Enfant"
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    AssignmentParentDashboardView()
        .environmentObject(AuthViewModel())
}
