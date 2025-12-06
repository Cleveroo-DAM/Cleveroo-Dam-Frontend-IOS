//
//  AssignmentViewModel.swift
//  Cleveroo
//
//  Created by GitHub Copilot on 24/11/2025.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Parent ViewModel
class AssignmentParentViewModel: ObservableObject {
    @Published var assignments: [Assignment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let assignmentService = AssignmentService.shared
    private var cancellables = Set<AnyCancellable>()
    private var parentToken: String {
        return UserDefaults.standard.string(forKey: "jwt") ?? ""
    }
    
    func setParentToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "jwt")
    }
    
    func loadMyAssignments() {
        isLoading = true
        errorMessage = nil
        
        assignmentService.getMyAssignments(token: parentToken)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors du chargement des assignments: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] assignments in
                    self?.assignments = assignments
                }
            )
            .store(in: &cancellables)
    }
    
    func createAssignment(request: CreateAssignmentRequest) {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        print("🔑 AssignmentParentViewModel: Using token: \(parentToken.isEmpty ? "EMPTY TOKEN!" : "Token length: \(parentToken.count)")")
        
        assignmentService.createAssignment(request: request, token: parentToken)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors de la création: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] assignment in
                    self?.assignments.insert(assignment, at: 0)
                    self?.successMessage = "Assignment créé avec succès!"
                }
            )
            .store(in: &cancellables)
    }
    
    func updateAssignment(assignmentId: String, request: UpdateAssignmentRequest) {
        isLoading = true
        errorMessage = nil
        
        assignmentService.updateAssignment(assignmentId: assignmentId, request: request, token: parentToken)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors de la modification: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] updatedAssignment in
                    if let index = self?.assignments.firstIndex(where: { $0.id == assignmentId }) {
                        self?.assignments[index] = updatedAssignment
                        self?.successMessage = "Assignment modifié avec succès!"
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func deleteAssignment(assignmentId: String) {
        isLoading = true
        errorMessage = nil
        
        assignmentService.deleteAssignment(assignmentId: assignmentId, token: parentToken)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors de la suppression: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.assignments.removeAll { $0.id == assignmentId }
                    self?.successMessage = "Assignment supprimé avec succès!"
                }
            )
            .store(in: &cancellables)
    }
    
    func approveSubmission(assignmentId: String, feedback: String?) {
        isLoading = true
        errorMessage = nil
        
        assignmentService.approveSubmission(assignmentId: assignmentId, feedback: feedback, token: parentToken)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors de l'approbation: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] updatedAssignment in
                    if let index = self?.assignments.firstIndex(where: { $0.id == assignmentId }) {
                        self?.assignments[index] = updatedAssignment
                        self?.successMessage = "Soumission approuvée!"
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func rejectSubmission(assignmentId: String, feedback: String?) {
        isLoading = true
        errorMessage = nil
        
        assignmentService.rejectSubmission(assignmentId: assignmentId, feedback: feedback, token: parentToken)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors du rejet: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] updatedAssignment in
                    if let index = self?.assignments.firstIndex(where: { $0.id == assignmentId }) {
                        self?.assignments[index] = updatedAssignment
                        self?.successMessage = "Soumission rejetée avec commentaire"
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}

// MARK: - Child ViewModel
class AssignmentChildViewModel: ObservableObject {
    @Published var assignments: [Assignment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isSubmitting = false
    
    private let assignmentService = AssignmentService.shared
    private var cancellables = Set<AnyCancellable>()
    private var childToken: String {
        return UserDefaults.standard.string(forKey: "jwt") ?? ""
    }
    
    func setChildToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "jwt")
    }
    
    func loadMyAssignments() {
        isLoading = true
        errorMessage = nil
        
        print("🔑 AssignmentChildViewModel: Using token: \(childToken.isEmpty ? "EMPTY TOKEN!" : "Token length: \(childToken.count)")")
        
        assignmentService.getChildAssignments(token: childToken)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("❌ AssignmentChildViewModel: Error loading assignments: \(error.localizedDescription)")
                        self?.errorMessage = "Erreur lors du chargement: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] assignments in
                    print("✅ AssignmentChildViewModel: Received \(assignments.count) assignments")
                    for (index, assignment) in assignments.enumerated() {
                        print("📋 Assignment \(index + 1): '\(assignment.title)' - Status: \(assignment.status) - Type: \(assignment.type)")
                    }
                    self?.assignments = assignments
                }
            )
            .store(in: &cancellables)
    }
    
    func startAssignment(assignmentId: String) {
        isLoading = true
        errorMessage = nil
        
        assignmentService.startAssignment(assignmentId: assignmentId, token: childToken)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors du démarrage: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] updatedAssignment in
                    if let index = self?.assignments.firstIndex(where: { $0.id == assignmentId }) {
                        self?.assignments[index] = updatedAssignment
                        self?.successMessage = "Assignment commencé!"
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func submitAssignment(assignmentId: String, photos: [UIImage], comment: String?) {
        guard let childToken = UserDefaults.standard.string(forKey: "jwt") else {
            errorMessage = "Non authentifié"
            return
        }
        
        isSubmitting = true
        errorMessage = nil
        
        print("🖼️ AssignmentChildViewModel: Processing \(photos.count) images for submission")
        
        // Envoyer directement les images au service (qui gérera la compression et le multipart)
        assignmentService.submitAssignment(assignmentId: assignmentId, images: photos, comment: comment, token: childToken)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isSubmitting = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors de la soumission: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] updatedAssignment in
                    if let index = self?.assignments.firstIndex(where: { $0.id == assignmentId }) {
                        self?.assignments[index] = updatedAssignment
                        self?.successMessage = "Assignment soumis avec succès!"
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
    
    // Helper function to resize images
    private func resizeImage(_ image: UIImage, maxSize: CGFloat) -> UIImage {
        let size = image.size
        let ratio = min(maxSize / size.width, maxSize / size.height)
        
        // If image is already smaller, don't resize
        if ratio >= 1.0 {
            return image
        }
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
    
    // Helper functions
    var pendingAssignments: [Assignment] {
        assignments.filter { $0.status == .assigned || $0.status == .inProgress }
    }
    
    var submittedAssignments: [Assignment] {
        assignments.filter { $0.status == .submitted }
    }
    
    var completedAssignments: [Assignment] {
        assignments.filter { $0.status == .approved || $0.status == .submitted }
    }
    
    var rejectedAssignments: [Assignment] {
        assignments.filter { $0.status == .rejected }
    }
}
