//
//  AssignmentDetailView.swift
//  Cleveroo
//
//  Created by GitHub Copilot on 24/11/2025.
//

import SwiftUI

struct AssignmentDetailView: View {
    let assignment: Assignment
    @ObservedObject var viewModel: AssignmentParentViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var feedbackText = ""
    @State private var showingApprovalAlert = false
    @State private var showingRejectionAlert = false
    @State private var selectedPhotoIndex = 0
    @State private var showingPhotoViewer = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color.indigo.opacity(0.6),
                        Color.purple.opacity(0.4),
                        Color.pink.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Assignment info
                        assignmentInfoSection
                        
                        // Submission section (if submitted)
                        if assignment.status == .submitted || assignment.status == .approved || assignment.status == .rejected {
                            submissionSection
                        }
                        
                        // Action buttons
                        if assignment.status == .submitted {
                            actionButtonsSection
                        }
                        
                        // Feedback section (if reviewed)
                        if let feedback = assignment.parentFeedback, !feedback.isEmpty {
                            feedbackSection
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Détails Assignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingPhotoViewer) {
            PhotoViewerView(photos: assignment.submissionPhotos, selectedIndex: $selectedPhotoIndex)
        }
        .alert("Approuver l'assignment", isPresented: $showingApprovalAlert) {
            TextField("Commentaire (optionnel)", text: $feedbackText)
            Button("Approuver") {
                viewModel.approveSubmission(assignmentId: assignment.id, feedback: feedbackText.isEmpty ? nil : feedbackText)
                dismiss()
            }
            Button("Annuler", role: .cancel) { }
        } message: {
            Text("Voulez-vous approuver cette soumission ?")
        }
        .alert("Rejeter l'assignment", isPresented: $showingRejectionAlert) {
            TextField("Raison du rejet", text: $feedbackText)
            Button("Rejeter", role: .destructive) {
                viewModel.rejectSubmission(assignmentId: assignment.id, feedback: feedbackText.isEmpty ? nil : feedbackText)
                dismiss()
            }
            Button("Annuler", role: .cancel) { }
        } message: {
            Text("Pourquoi rejetez-vous cette soumission ?")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: assignment.type.icon)
                .font(.system(size: 50))
                .foregroundColor(.white)
            
            Text(assignment.title)
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            AssignmentStatusBadge(status: assignment.status)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2))
        )
    }
    
    private var assignmentInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Informations")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                AssignmentInfoRow(title: "Type", value: assignment.type.displayName, icon: assignment.type.icon)
                
                if let description = assignment.description {
                    AssignmentInfoRow(title: "Description", value: description, icon: "text.alignleft")
                }
                
                if let dueDate = assignment.dueDate {
                    AssignmentInfoRow(title: "Date limite", value: DateFormatter.shortDate.string(from: dueDate), icon: "calendar")
                }
                
                if let points = assignment.rewardPoints {
                    AssignmentInfoRow(title: "Points", value: "\(points)", icon: "star.fill")
                }
                
                AssignmentInfoRow(title: "Créé le", value: DateFormatter.shortDateTime.string(from: assignment.createdAt), icon: "clock")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2))
        )
    }
    
    private var submissionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Soumission de l'enfant")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                if let submittedAt = assignment.submittedAt {
                    AssignmentInfoRow(title: "Soumis le", value: DateFormatter.shortDateTime.string(from: submittedAt), icon: "clock.fill")
                }
                
                if let comment = assignment.submissionComment, !comment.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "quote.bubble")
                                .foregroundColor(.white.opacity(0.8))
                            Text("Commentaire:")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Text(comment)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                }
                
                // Photos
                if !assignment.submissionPhotos.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "photo")
                                .foregroundColor(.white.opacity(0.8))
                            Text("Photos (\(assignment.submissionPhotos.count)):")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(assignment.submissionPhotos.indices, id: \.self) { index in
                                    Button(action: {
                                        selectedPhotoIndex = index
                                        showingPhotoViewer = true
                                    }) {
                                        AsyncImage(url: URL(string: "\(APIConfig.baseURL)\(assignment.submissionPhotos[index])")) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.white.opacity(0.2))
                                                .overlay(
                                                    ProgressView()
                                                        .tint(.white)
                                                )
                                        }
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2))
        )
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Text("Évaluer la soumission")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                Button(action: {
                    feedbackText = ""
                    showingRejectionAlert = true
                }) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Rejeter")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    feedbackText = ""
                    showingApprovalAlert = true
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Approuver")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Votre feedback")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                if let reviewedAt = assignment.reviewedAt {
                    Text("Évalué le \(DateFormatter.shortDateTime.string(from: reviewedAt))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Text(assignment.parentFeedback!)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2))
        )
    }
}

struct AssignmentInfoRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 20)
            
            Text(title + ":")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
        }
    }
}

struct PhotoViewerView: View {
    let photos: [String]
    @Binding var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                TabView(selection: $selectedIndex) {
                    ForEach(photos.indices, id: \.self) { index in
                        AsyncImage(url: URL(string: "\(APIConfig.baseURL)\(photos[index])")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                                .tint(.white)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
            .navigationTitle("Photo \(selectedIndex + 1) sur \(photos.count)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}



#Preview {
    // Create a sample assignment using JSON data to avoid initialization issues
    let sampleAssignmentJSON = """
    {
        "_id": "1",
        "title": "Dessiner un arbre",
        "description": "Dessine un arbre avec des feuilles colorées",
        "type": "drawing",
        "status": "submitted",
        "parentId": "parent1",
        "childId": "child1",
        "dueDate": "2025-12-01T12:00:00.000Z",
        "rewardPoints": 10,
        "submissionPhotos": [],
        "submissionComment": "J'ai fini mon dessin !",
        "submittedAt": "2025-11-30T11:00:00.000Z",
        "createdAt": "2025-11-30T10:00:00.000Z",
        "updatedAt": "2025-11-30T11:00:00.000Z"
    }
    """.data(using: .utf8)!
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let sampleAssignment = try! decoder.decode(Assignment.self, from: sampleAssignmentJSON)
    
    return AssignmentDetailView(
        assignment: sampleAssignment,
        viewModel: AssignmentParentViewModel()
    )
}
