//
//  RestrictedAccessView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 30/11/2025.
//

import SwiftUI

struct RestrictedAccessView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ChildRestrictionViewModel()
    @State private var showRequestDialog = false
    @State private var requestReason = ""
    @State private var showAllRequests = false
    @State private var refreshTask: Task<Void, Never>?
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 1.0, green: 0.42, blue: 0.42), Color(red: 1.0, green: 0.9, blue: 0.43)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Lock Icon
                Image(systemName: "lock.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                
                // Title
                Text("Accès Restreint")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Reason
                if let control = viewModel.parentalControl {
                    let (isRestricted, reason) = viewModel.isCurrentlyRestricted()
                    if isRestricted, let reasonText = reason {
                        Text(reasonText)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else if let status = viewModel.restrictionStatus, let reason = status.reason {
                    Text(reason)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Time Slots Info
                if let control = viewModel.parentalControl,
                   let timeSlots = control.allowedTimeSlots,
                   !timeSlots.isEmpty {
                    VStack(spacing: 8) {
                        Text("Plages horaires autorisées")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        ForEach(timeSlots.prefix(3), id: \.self) { slot in
                            Text(slot)
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Screen Time Remaining
                if let control = viewModel.parentalControl, control.dailyScreenTimeLimit != nil {
                    VStack(spacing: 8) {
                        Text("Temps d'écran restant")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(viewModel.getRemainingScreenTime())
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                }
                
                // Request Unblock Button
                VStack(spacing: 15) {
                    Button(action: {
                        showRequestDialog = true
                    }) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                            Text("Demander l'accès")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.42))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    
                    // My Requests Status
                    if !viewModel.myRequests.isEmpty {
                        VStack(spacing: 10) {
                            Text("Mes demandes")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            ForEach(viewModel.myRequests.prefix(3)) { request in
                                HStack {
                                    Image(systemName: statusIcon(request.status))
                                    Text(statusText(request.status))
                                        .font(.subheadline)
                                    Spacer()
                                    if let response = request.parentResponse {
                                        Text(response)
                                            .font(.caption)
                                            .lineLimit(1)
                                    }
                                }
                                .foregroundColor(.white.opacity(0.9))
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                            }
                            
                            // Bouton pour voir toutes les demandes
                            NavigationLink(destination: MyUnblockRequestsListView()) {
                                HStack {
                                    Text("Voir toutes mes demandes")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                }
                
                // Screen Time Info
                if let screenTime = viewModel.screenTimeData {
                    VStack(spacing: 8) {
                        Text("Temps d'écran aujourd'hui")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(screenTime.hours)h \(screenTime.minutes)m")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                }
                
                Spacer()
                
                // Change Role Button
                Button(action: {
                    // Reset auth fields and prepare for role change
                    authViewModel.password = ""
                    authViewModel.identifier = ""
                    authViewModel.errorMessage = nil
                    authViewModel.isLoggedIn = false
                    authViewModel.isParent = false
                    authViewModel.childId = nil
                    authViewModel.isChildRestricted = false
                    authViewModel.restrictionReason = nil
                    // Save to UserDefaults to persist logout
                    UserDefaults.standard.removeObject(forKey: "jwt")
                    UserDefaults.standard.removeObject(forKey: "childId")
                }) {
                    HStack {
                        Image(systemName: "person.badge.key.fill")
                        Text("Changer de rôle")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                
                // Info Text
                Text("Contacte tes parents pour plus d'informations")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Load data only if not already loaded
            if viewModel.parentalControl == nil {
                refreshTask?.cancel()
                refreshTask = Task {
                    await loadDataPeriodically()
                }
            }
        }
        .onDisappear {
            refreshTask?.cancel()
            refreshTask = nil
        }
        .alert("Demander l'accès", isPresented: $showRequestDialog) {
            TextField("Pourquoi as-tu besoin d'accéder ?", text: $requestReason)
            Button("Annuler", role: .cancel) { }
            Button("Envoyer") {
                Task {
                    await viewModel.requestUnblock(reason: requestReason)
                    requestReason = ""
                }
            }
        } message: {
            Text("Explique pourquoi tu as besoin d'accéder à l'application")
        }
        .alert("Succès", isPresented: .constant(viewModel.successMessage != nil)) {
            Button("OK") {
                viewModel.successMessage = nil
                Task {
                    await viewModel.loadMyRequests()
                }
            }
        } message: {
            if let message = viewModel.successMessage {
                Text(message)
            }
        }
        }
    }
    
    private func loadDataPeriodically() async {
        // Initial load
        await viewModel.loadMyParentalControl()
        await viewModel.checkRestrictionStatus()
        await viewModel.loadMyRequests()
        await viewModel.loadMyScreenTime()
        
        // Refresh every 30 seconds
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 30_000_000_000)
            
            guard !Task.isCancelled else { break }
            
            await viewModel.loadMyParentalControl()
            await viewModel.loadMyScreenTime()
            await viewModel.loadMyRequests()
        }
    }
    
    private func statusIcon(_ status: String) -> String {
        switch status {
        case "pending": return "clock"
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
}

#Preview {
    RestrictedAccessView(authViewModel: AuthViewModel())
}
