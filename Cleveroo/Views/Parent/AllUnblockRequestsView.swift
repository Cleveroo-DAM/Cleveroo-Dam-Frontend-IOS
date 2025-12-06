//
//  AllUnblockRequestsView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 30/11/2025.
//

import SwiftUI

struct AllUnblockRequestsView: View {
    @StateObject private var viewModel = ParentalControlViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedFilter: RequestFilter = .pending
    @State private var showResponseDialog = false
    @State private var selectedRequest: UnblockRequest?
    @State private var parentResponse = ""
    
    enum RequestFilter: String, CaseIterable {
        case all = "Toutes"
        case pending = "En attente"
        case approved = "Approuvées"
        case rejected = "Rejetées"
        
        var statusValue: String? {
            switch self {
            case .all: return nil
            case .pending: return "pending"
            case .approved: return "approved"
            case .rejected: return "rejected"
            }
        }
    }
    
    var filteredRequests: [UnblockRequest] {
        viewModel.unblockRequests
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.97, blue: 0.98)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter Tabs
                    filterTabsView
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Chargement...")
                        Spacer()
                    } else if filteredRequests.isEmpty {
                        emptyStateView
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(filteredRequests) { request in
                                    requestCard(request)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Demandes de déblocage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadRequests()
            }
            .sheet(isPresented: $showResponseDialog) {
                if let request = selectedRequest {
                    responseDialogView(for: request)
                }
            }
        }
    }
    
    private var filterTabsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(RequestFilter.allCases, id: \.self) { filter in
                    filterTab(filter)
                }
            }
            .padding()
        }
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    private func filterTab(_ filter: RequestFilter) -> some View {
        Button(action: {
            selectedFilter = filter
            Task {
                await loadRequests()
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: iconForFilter(filter))
                    .font(.system(size: 14))
                Text(filter.rawValue)
                    .font(.subheadline)
                    .fontWeight(selectedFilter == filter ? .bold : .regular)
                
                // Count badge
                let count = countForFilter(filter)
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(selectedFilter == filter ? Color.white.opacity(0.3) : Color.gray.opacity(0.6))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(selectedFilter == filter ? colorForFilter(filter) : Color.gray.opacity(0.1))
            .foregroundColor(selectedFilter == filter ? .white : .gray)
            .cornerRadius(20)
        }
    }
    
    private func requestCard(_ request: UnblockRequest) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header avec enfant
            HStack(spacing: 12) {
                // Avatar de l'enfant
                if let avatar = request.childAvatar {
                    AsyncImage(url: URL(string: avatar)) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: 50, height: 50)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.childUsername ?? "Enfant")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    if let createdAt = request.createdAt {
                        Text(formatDate(createdAt))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Status badge
                statusBadge(request.status)
            }
            
            // Raison
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "text.bubble")
                        .foregroundColor(.blue)
                        .font(.system(size: 14))
                    Text("Raison :")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                
                Text(request.reason)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(8)
            }
            
            // Réponse du parent si existe
            if let response = request.parentResponse, !response.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .foregroundColor(.purple)
                            .font(.system(size: 14))
                        Text("Votre réponse :")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(response)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.purple.opacity(0.05))
                        .cornerRadius(8)
                }
            }
            
            // Actions pour les demandes en attente
            if request.status == "pending" {
                HStack(spacing: 12) {
                    Button(action: {
                        selectedRequest = request
                        showResponseDialog = true
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Approuver")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        Task {
                            await respondToRequest(request, approve: false)
                        }
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Rejeter")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private func statusBadge(_ status: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: statusIcon(status))
                .font(.system(size: 12))
            Text(statusText(status))
                .font(.caption)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(statusColor(status).opacity(0.2))
        .foregroundColor(statusColor(status))
        .cornerRadius(12)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "tray.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Aucune demande")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            
            Text("Il n'y a pas de demandes de déblocage \(selectedFilter.rawValue.lowercased())")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    private func responseDialogView(for request: UnblockRequest) -> some View {
        NavigationView {
            VStack(spacing: 20) {
                // Enfant info
                HStack(spacing: 12) {
                    if let avatar = request.childAvatar {
                        AsyncImage(url: URL(string: avatar)) { image in
                            image.resizable()
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading) {
                        Text(request.childUsername ?? "Enfant")
                            .font(.headline)
                        Text("Demande de déblocage")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                
                // Raison
                VStack(alignment: .leading, spacing: 8) {
                    Text("Raison de la demande :")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(request.reason)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Réponse optionnelle
                VStack(alignment: .leading, spacing: 8) {
                    Text("Votre message (optionnel) :")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    TextEditor(text: $parentResponse)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                Spacer()
                
                // Actions
                VStack(spacing: 12) {
                    Button(action: {
                        Task {
                            await respondToRequest(request, approve: true, response: parentResponse.isEmpty ? nil : parentResponse)
                            showResponseDialog = false
                            parentResponse = ""
                        }
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Approuver et débloquer")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showResponseDialog = false
                        parentResponse = ""
                    }) {
                        Text("Annuler")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .navigationTitle("Répondre à la demande")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadRequests() async {
        await viewModel.loadUnblockRequests(status: selectedFilter.statusValue)
    }
    
    private func respondToRequest(_ request: UnblockRequest, approve: Bool, response: String? = nil) async {
        await viewModel.respondToRequest(request.id, approve: approve, response: response)
        await loadRequests()
    }
    
    private func iconForFilter(_ filter: RequestFilter) -> String {
        switch filter {
        case .all: return "list.bullet"
        case .pending: return "clock"
        case .approved: return "checkmark.circle"
        case .rejected: return "xmark.circle"
        }
    }
    
    private func colorForFilter(_ filter: RequestFilter) -> Color {
        switch filter {
        case .all: return .blue
        case .pending: return .orange
        case .approved: return .green
        case .rejected: return .red
        }
    }
    
    private func countForFilter(_ filter: RequestFilter) -> Int {
        switch filter {
        case .all:
            return viewModel.unblockRequests.count
        case .pending:
            return viewModel.unblockRequests.filter { $0.status == "pending" }.count
        case .approved:
            return viewModel.unblockRequests.filter { $0.status == "approved" }.count
        case .rejected:
            return viewModel.unblockRequests.filter { $0.status == "rejected" }.count
        }
    }
    
    private func statusIcon(_ status: String) -> String {
        switch status {
        case "pending": return "clock.fill"
        case "approved": return "checkmark.circle.fill"
        case "rejected": return "xmark.circle.fill"
        default: return "circle"
        }
    }
    
    private func statusText(_ status: String) -> String {
        switch status {
        case "pending": return "En attente"
        case "approved": return "Approuvée"
        case "rejected": return "Rejetée"
        default: return status
        }
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "pending": return .orange
        case "approved": return .green
        case "rejected": return .red
        default: return .gray
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "fr_FR")
        
        return displayFormatter.string(from: date)
    }
}

#Preview {
    AllUnblockRequestsView()
}
