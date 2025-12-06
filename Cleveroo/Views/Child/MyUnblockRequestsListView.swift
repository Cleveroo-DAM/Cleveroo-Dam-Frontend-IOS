//
//  MyUnblockRequestsListView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 30/11/2025.
//

import SwiftUI

struct MyUnblockRequestsListView: View {
    @StateObject private var viewModel = ChildRestrictionViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.97, blue: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    ProgressView("Chargement...")
                        .frame(maxHeight: .infinity)
                } else if viewModel.myRequests.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(viewModel.myRequests) { request in
                                MyUnblockRequestCard(request: request)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Mes Demandes")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadMyRequests()
        }
        .refreshable {
            await viewModel.loadMyRequests()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Aucune demande")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("Tu n'as pas encore envoyé de demande de déblocage")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - My Unblock Request Card
struct MyUnblockRequestCard: View {
    let request: UnblockRequest
    
    var statusColor: Color {
        switch request.status {
        case "pending": return .orange
        case "approved": return .green
        case "rejected": return .red
        default: return .gray
        }
    }
    
    var statusText: String {
        switch request.status {
        case "pending": return "En attente"
        case "approved": return "Approuvée ✓"
        case "rejected": return "Refusée ✗"
        default: return request.status
        }
    }
    
    var statusIcon: String {
        switch request.status {
        case "pending": return "clock.fill"
        case "approved": return "checkmark.circle.fill"
        case "rejected": return "xmark.circle.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header avec statut
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: statusIcon)
                        .foregroundColor(statusColor)
                        .font(.title3)
                    
                    Text(statusText)
                        .font(.headline)
                        .foregroundColor(statusColor)
                }
                
                Spacer()
                
                if let date = request.createdAt {
                    Text(formatDate(date))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
            
            // Ta demande
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Image(systemName: "text.bubble.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text("Ta demande :")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(request.reason)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.leading, 20)
            }
            
            // Réponse du parent
            if let response = request.parentResponse, !response.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.purple)
                            .font(.caption)
                        Text("Réponse du parent :")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Text(response)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.leading, 20)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            // Date de réponse
            if let respondedAt = request.respondedAt {
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Répondu le \(formatDate(respondedAt))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Badge de statut en bas
            HStack {
                Spacer()
                statusBadge
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(statusText)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(statusColor.opacity(0.1))
        .cornerRadius(8)
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

#Preview {
    NavigationStack {
        MyUnblockRequestsListView()
    }
}
