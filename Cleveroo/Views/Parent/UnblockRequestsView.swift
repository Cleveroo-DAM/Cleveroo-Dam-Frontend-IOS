//
//  UnblockRequestsView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 30/11/2025.
//

import SwiftUI

struct UnblockRequestsView: View {
    @StateObject private var viewModel = ParentalControlViewModel()
    @State private var selectedStatus: String? = "pending"
    @State private var showResponseDialog = false
    @State private var selectedRequest: UnblockRequest?
    @State private var responseText = ""
    @State private var approveRequest = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.97, blue: 0.98)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter Picker
                    Picker("Statut", selection: $selectedStatus) {
                        Text("En attente").tag("pending" as String?)
                        Text("Approuvées").tag("approved" as String?)
                        Text("Rejetées").tag("rejected" as String?)
                        Text("Toutes").tag(nil as String?)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    if viewModel.isLoading {
                        ProgressView("Chargement...")
                            .frame(maxHeight: .infinity)
                    } else if viewModel.unblockRequests.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "tray")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("Aucune demande")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(viewModel.unblockRequests) { request in
                                    UnblockRequestCard(
                                        request: request,
                                        onRespond: { approve in
                                            selectedRequest = request
                                            approveRequest = approve
                                            showResponseDialog = true
                                        }
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Demandes de déblocage")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadUnblockRequests(status: selectedStatus)
            }
            .onChange(of: selectedStatus) { _ in
                Task {
                    await viewModel.loadUnblockRequests(status: selectedStatus)
                }
            }
            .alert(approveRequest ? "Approuver la demande" : "Rejeter la demande", isPresented: $showResponseDialog) {
                TextField("Réponse (optionnel)", text: $responseText)
                Button("Annuler", role: .cancel) { }
                Button(approveRequest ? "Approuver" : "Rejeter", role: approveRequest ? .none : .destructive) {
                    if let request = selectedRequest {
                        Task {
                            await viewModel.respondToRequest(
                                request.id,
                                approve: approveRequest,
                                response: responseText.isEmpty ? nil : responseText
                            )
                            responseText = ""
                        }
                    }
                }
            } message: {
                if let request = selectedRequest {
                    Text("Raison: \(request.reason)")
                }
            }
        }
    }
}

struct UnblockRequestCard: View {
    let request: UnblockRequest
    let onRespond: ((Bool) -> Void)?
    
    var childName: String {
        // Le childId est une String, on affiche "Enfant" pour l'instant
        // Le backend devrait retourner le nom de l'enfant dans le populate
        return "Enfant"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header avec nom de l'enfant et statut
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.blue)
                        Text(childName)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    if let createdAt = request.createdAt {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption2)
                            Text(formatDate(createdAt))
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                UnblockRequestStatusBadge(status: request.status)
            }
            
            Divider()
            
            // Raison de la demande
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "text.bubble.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("Raison de la demande:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text(request.reason)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding(.leading, 20)
            }
            
            // Réponse du parent (si existe)
            if let response = request.parentResponse, !response.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.bubble.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text("Votre réponse:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(response)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding(.leading, 20)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            // Date de réponse
            if let respondedAt = request.respondedAt {
                HStack(spacing: 4) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.caption2)
                    Text("Répondu le \(formatDate(respondedAt))")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            // Boutons d'action (seulement si en attente)
            if request.status == "pending", let onRespond = onRespond {
                Divider()
                
                HStack(spacing: 12) {
                    Button(action: {
                        onRespond(false)
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Rejeter")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        onRespond(true)
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Approuver")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            displayFormatter.locale = Locale(identifier: "fr_FR")
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

struct UnblockRequestStatusBadge: View {
    let status: String
    
    var color: Color {
        switch status {
        case "pending": return .orange
        case "approved": return .green
        case "rejected": return .red
        default: return .gray
        }
    }
    
    var icon: String {
        switch status {
        case "pending": return "clock"
        case "approved": return "checkmark.circle.fill"
        case "rejected": return "xmark.circle.fill"
        default: return "circle"
        }
    }
    
    var text: String {
        switch status {
        case "pending": return "En attente"
        case "approved": return "Approuvée"
        case "rejected": return "Rejetée"
        default: return status
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}
