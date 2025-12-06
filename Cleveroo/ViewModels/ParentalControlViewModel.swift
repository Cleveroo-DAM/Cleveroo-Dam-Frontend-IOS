//
//  ParentalControlViewModel.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 30/11/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ParentalControlViewModel: ObservableObject {
    @Published var parentalControl: ParentalControl?
    @Published var unblockRequests: [UnblockRequest] = []
    @Published var screenTimeData: ScreenTimeData?
    @Published var screenTimeHistory: [ScreenTimeHistoryEntry] = []
    @Published var history: [ParentalControlHistory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = ParentalControlService.shared
    
    // MARK: - Parent Functions
    
    func loadParentalControl(for childId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            parentalControl = try await service.getChildParentalControl(childId: childId)
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error loading parental control: \(error)")
        }
        
        isLoading = false
    }
    
    func blockChild(_ childId: String, reason: String? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await service.setChildBlockStatus(childId: childId, isBlocked: true, blockReason: reason)
            await loadParentalControl(for: childId)
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error blocking child: \(error)")
        }
        
        isLoading = false
    }
    
    func unblockChild(_ childId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await service.setChildBlockStatus(childId: childId, isBlocked: false)
            await loadParentalControl(for: childId)
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error unblocking child: \(error)")
        }
        
        isLoading = false
    }
    
    func updateTimeSlots(_ childId: String, timeSlots: [String]) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await service.setChildTimeSlots(childId: childId, allowedTimeSlots: timeSlots)
            await loadParentalControl(for: childId)
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error updating time slots: \(error)")
        }
        
        isLoading = false
    }
    
    func updateScreenTimeLimit(_ childId: String, limitMinutes: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await service.setChildScreenTimeLimit(childId: childId, dailyScreenTimeLimit: limitMinutes)
            await loadParentalControl(for: childId)
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error updating screen time limit: \(error)")
        }
        
        isLoading = false
    }
    
    func loadUnblockRequests(status: String? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            unblockRequests = try await service.getUnblockRequests(status: status)
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error loading unblock requests: \(error)")
        }
        
        isLoading = false
    }
    
    func respondToRequest(_ requestId: String, approve: Bool, response: String? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await service.respondToUnblockRequest(requestId: requestId, approve: approve, parentResponse: response)
            await loadUnblockRequests()
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error responding to request: \(error)")
        }
        
        isLoading = false
    }
    
    func loadScreenTime(for childId: String) async {
        do {
            screenTimeData = try await service.getTodayScreenTime(childId: childId)
        } catch {
            print("❌ Error loading screen time: \(error)")
        }
    }
    
    func loadScreenTimeHistory(for childId: String, days: Int = 7) async {
        do {
            screenTimeHistory = try await service.getScreenTimeHistory(childId: childId, days: days)
        } catch {
            print("❌ Error loading screen time history: \(error)")
        }
    }
    
    func loadHistory(for childId: String, limit: Int = 20) async {
        do {
            history = try await service.getChildHistory(childId: childId, limit: limit)
        } catch {
            print("❌ Error loading history: \(error)")
        }
    }
}

// MARK: - Child ViewModel

@MainActor
class ChildRestrictionViewModel: ObservableObject {
    @Published var restrictionStatus: RestrictionStatus?
    @Published var myRequests: [UnblockRequest] = []
    @Published var screenTimeData: ScreenTimeData?
    @Published var screenTimeHistory: [ScreenTimeHistoryEntry] = []
    @Published var parentalControl: ParentalControl?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let service = ParentalControlService.shared
    private let restrictionChecker = RestrictionChecker.shared
    
    // Track ongoing tasks to prevent concurrent calls
    private var loadParentalControlTask: Task<Void, Never>?
    private var loadScreenTimeTask: Task<Void, Never>?
    private var loadRequestsTask: Task<Void, Never>?
    
    /// Vérifier si l'enfant est actuellement restreint (plages horaires + screen time + blocage manuel)
    func isCurrentlyRestricted() -> (restricted: Bool, reason: String?) {
        guard let control = parentalControl else {
            return (false, nil)
        }
        
        // 1. Vérifier le blocage manuel
        if control.isBlocked == true {
            return (true, control.blockReason ?? "Accès bloqué par le parent")
        }
        
        // 2. Vérifier les plages horaires
        if let timeSlots = control.allowedTimeSlots, !timeSlots.isEmpty {
            if !restrictionChecker.isWithinAllowedTimeSlots(timeSlots) {
                let nextSlot = restrictionChecker.timeUntilNextSlot(timeSlots)
                let reason = nextSlot != nil
                    ? "En dehors des heures autorisées. Prochaine session dans \(nextSlot!)"
                    : "En dehors des heures autorisées"
                return (true, reason)
            }
        }
        
        // 3. Vérifier la limite de temps d'écran
        if let screenTime = screenTimeData,
           let limit = control.dailyScreenTimeLimit,
           restrictionChecker.isScreenTimeLimitExceeded(usedMinutes: screenTime.totalMinutes, limitMinutes: limit) {
            return (true, "Limite de temps d'écran atteinte (\(limit) minutes)")
        }
        
        return (false, nil)
    }
    
    /// Obtenir le temps d'écran restant
    func getRemainingScreenTime() -> String {
        guard let screenTime = screenTimeData,
              let limit = parentalControl?.dailyScreenTimeLimit else {
            return "Illimité"
        }
        return restrictionChecker.remainingScreenTime(usedMinutes: screenTime.totalMinutes, limitMinutes: limit)
    }
    
    func checkRestrictionStatus() async {
        isLoading = true
        errorMessage = nil
        
        do {
            restrictionStatus = try await service.getRestrictionStatus()
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error checking restriction status: \(error)")
        }
        
        isLoading = false
    }
    
    func loadMyParentalControl() async {
        // Cancel any ongoing task
        loadParentalControlTask?.cancel()
        
        loadParentalControlTask = Task {
            do {
                let control = try await service.getMyParentalControl()
                guard !Task.isCancelled else { return }
                parentalControl = control
            } catch {
                guard !Task.isCancelled else { return }
                print("❌ Error loading parental control: \(error)")
            }
        }
        
        await loadParentalControlTask?.value
    }
    
    func requestUnblock(reason: String) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            try await service.createUnblockRequest(reason: reason)
            successMessage = "Demande envoyée au parent"
            await loadMyRequests()
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error creating unblock request: \(error)")
        }
        
        isLoading = false
    }
    
    func loadMyRequests() async {
        // Cancel any ongoing task
        loadRequestsTask?.cancel()
        
        loadRequestsTask = Task {
            do {
                let requests = try await service.getMyUnblockRequestStatus()
                guard !Task.isCancelled else { return }
                myRequests = requests
            } catch {
                guard !Task.isCancelled else { return }
                print("❌ Error loading requests: \(error)")
            }
        }
        
        await loadRequestsTask?.value
    }
    
    func loadMyScreenTime() async {
        // Cancel any ongoing task
        loadScreenTimeTask?.cancel()
        
        loadScreenTimeTask = Task {
            do {
                let screenTime = try await service.getMyScreenTimeToday()
                guard !Task.isCancelled else { return }
                screenTimeData = screenTime
            } catch {
                guard !Task.isCancelled else { return }
                print("❌ Error loading screen time: \(error)")
            }
        }
        
        await loadScreenTimeTask?.value
    }
    
    func loadMyScreenTimeHistory() async {
        do {
            screenTimeHistory = try await service.getMyScreenTimeHistory()
        } catch {
            print("❌ Error loading screen time history: \(error)")
        }
    }
}
