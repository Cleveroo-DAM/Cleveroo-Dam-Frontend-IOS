//
//  AssignmentChildDetailView.swift
//  Cleveroo
//
//  Created by GitHub Copilot on 24/11/2025.
//

import SwiftUI
import PhotosUI

struct AssignmentChildDetailView: View {
    let assignment: Assignment
    @ObservedObject var viewModel: AssignmentChildViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var submissionComment = ""
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    @State private var cameraImage: UIImage?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color.mint.opacity(0.6),
                        Color.cyan.opacity(0.4),
                        Color.blue.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Assignment details
                        assignmentDetailsSection
                        
                        // Action section based on status
                        actionSection
                        
                        // Submission section (if submitted)
                        if assignment.status == .submitted || assignment.status == .approved || assignment.status == .rejected {
                            submissionStatusSection
                        }
                        
                        // Parent feedback (if exists)
                        if let feedback = assignment.parentFeedback, !feedback.isEmpty {
                            parentFeedbackSection
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Ma Tâche")
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
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotos, maxSelectionCount: 5, matching: .images)
        .sheet(isPresented: $showingCamera) {
            CameraView(image: $cameraImage)
        }
        .onChange(of: selectedPhotos) { items in
            loadPhotos(from: items)
        }
        .onChange(of: cameraImage) { image in
            if let image = image {
                selectedImages.append(image)
                cameraImage = nil
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.3))
                    .frame(width: 80, height: 80)
                
                Image(systemName: assignment.type.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
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
    
    private var assignmentDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Détails de la tâche")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                if let description = assignment.description {
                    DetailRow(title: "Description", value: description, icon: "text.alignleft")
                }
                
                DetailRow(title: "Type", value: assignment.type.displayName, icon: assignment.type.icon)
                
                if let dueDate = assignment.dueDate {
                    DetailRow(title: "À terminer avant", value: DateFormatter.friendlyDate.string(from: dueDate), icon: "calendar", isUrgent: isUrgent(dueDate))
                }
                
                if let points = assignment.rewardPoints {
                    DetailRow(title: "Points à gagner", value: "\(points) ⭐", icon: "star.fill")
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2))
        )
    }
    
    private var actionSection: some View {
        Group {
            switch assignment.status {
            case .assigned:
                startAssignmentSection
            case .inProgress:
                submitAssignmentSection
            case .submitted:
                waitingForReviewSection
            case .approved:
                completedSection
            case .rejected:
                resubmitSection
            }
        }
    }
    
    private var startAssignmentSection: some View {
        VStack(spacing: 16) {
            Text("Prêt à commencer ?")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Clique sur le bouton pour commencer cette tâche !")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Button(action: {
                viewModel.startAssignment(assignmentId: assignment.id)
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "play.circle.fill")
                    }
                    Text(viewModel.isLoading ? "Démarrage..." : "Commencer la tâche")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(12)
            }
            .disabled(viewModel.isLoading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2))
        )
    }
    
    private var submitAssignmentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Soumettre ma tâche")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Prends des photos de ton travail terminé !")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            // Photo selection buttons
            HStack(spacing: 12) {
                Button(action: {
                    showingCamera = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Appareil photo")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(20)
                }
                
                Button(action: {
                    showingPhotoPicker = true
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Galerie")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.purple)
                    .cornerRadius(20)
                }
            }
            
            // Selected photos preview
            if !selectedImages.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Photos sélectionnées (\(selectedImages.count)/5):")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(selectedImages.indices, id: \.self) { index in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: selectedImages[index])
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipped()
                                        .cornerRadius(8)
                                    
                                    Button(action: {
                                        selectedImages.remove(at: index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .background(Color.white, in: Circle())
                                    }
                                    .offset(x: 8, y: -8)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
            
            // Comment section
            VStack(alignment: .leading, spacing: 8) {
                Text("Commentaire (optionnel):")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                TextField("Raconte-nous comment ça s'est passé !", text: $submissionComment, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...5)
            }
            
            // Submit button
            Button(action: submitAssignment) {
                HStack {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                    Text(viewModel.isSubmitting ? "Envoi en cours..." : "Soumettre ma tâche")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(canSubmit ? Color.green : Color.gray)
                .cornerRadius(12)
            }
            .disabled(!canSubmit || viewModel.isSubmitting)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2))
        )
    }
    
    private var waitingForReviewSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Tâche soumise !")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Ton parent va examiner ton travail. Tu recevras une notification quand ce sera évalué.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.2))
        )
    }
    
    private var completedSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
            Text("Bravo !")
                .font(.title.weight(.bold))
                .foregroundColor(.white)
            
            Text("Ta tâche a été approuvée !")
                .font(.headline)
                .foregroundColor(.white)
            
            if let points = assignment.rewardPoints {
                HStack {
                    Text("Tu as gagné")
                    Text("\(points)")
                        .fontWeight(.bold)
                    Text("⭐ points !")
                }
                .font(.title2)
                .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.2))
        )
    }
    
    private var resubmitSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.clockwise.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("À améliorer")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Ton parent a demandé des améliorations. Regarde ses commentaires ci-dessous et réessaie !")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Button(action: {
                viewModel.startAssignment(assignmentId: assignment.id)
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Recommencer")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.2))
        )
    }
    
    private var submissionStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ma soumission")
                .font(.headline)
                .foregroundColor(.white)
            
            if let submittedAt = assignment.submittedAt {
                Text("Soumis le \(DateFormatter.friendlyDateTime.string(from: submittedAt))")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            if let comment = assignment.submissionComment, !comment.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mon commentaire:")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
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
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2))
        )
    }
    
    private var parentFeedbackSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "quote.bubble.fill")
                    .foregroundColor(.white)
                Text("Message de tes parents")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Text(assignment.parentFeedback!)
                .font(.body)
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(feedbackBackgroundColor)
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2))
        )
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
    
    private var feedbackBackgroundColor: Color {
        switch assignment.status {
        case .approved: return Color.green.opacity(0.2)
        case .rejected: return Color.red.opacity(0.2)
        default: return Color.white.opacity(0.1)
        }
    }
    
    private var canSubmit: Bool {
        !selectedImages.isEmpty
    }
    
    private func isUrgent(_ date: Date) -> Bool {
        let timeInterval = date.timeIntervalSince(Date())
        return timeInterval < 24 * 60 * 60 // Less than 24 hours
    }
    
    private func loadPhotos(from items: [PhotosPickerItem]) {
        for item in items {
            item.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            if selectedImages.count < 5 {
                                selectedImages.append(image)
                            }
                        }
                    }
                case .failure(let error):
                    print("Error loading photo: \(error)")
                }
            }
        }
        selectedPhotos = []
    }
    
    private func submitAssignment() {
        viewModel.submitAssignment(
            assignmentId: assignment.id,
            photos: selectedImages,
            comment: submissionComment.isEmpty ? nil : submissionComment
        )
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    let isUrgent: Bool
    
    init(title: String, value: String, icon: String, isUrgent: Bool = false) {
        self.title = title
        self.value = value
        self.icon = icon
        self.isUrgent = isUrgent
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(isUrgent ? .red : .white.opacity(0.8))
                .frame(width: 20)
            
            Text(title + ":")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundColor(isUrgent ? .red : .white)
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

extension DateFormatter {
    static let friendlyDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
    
    static let friendlyDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    // Create a sample assignment using JSON data to avoid initialization issues
    let sampleAssignmentJSON = """
    {
        "_id": "1",
        "title": "Dessiner un arbre",
        "description": "Dessine un arbre avec des feuilles colorées",
        "type": "drawing",
        "status": "in_progress",
        "parentId": "parent1",
        "childId": "child1",
        "dueDate": "2025-12-01T12:00:00.000Z",
        "rewardPoints": 10,
        "submissionPhotos": [],
        "createdAt": "2025-11-30T12:00:00.000Z",
        "updatedAt": "2025-11-30T12:00:00.000Z"
    }
    """.data(using: .utf8)!
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let sampleAssignment = try! decoder.decode(Assignment.self, from: sampleAssignmentJSON)
    
    return AssignmentChildDetailView(
        assignment: sampleAssignment,
        viewModel: AssignmentChildViewModel()
    )
}
