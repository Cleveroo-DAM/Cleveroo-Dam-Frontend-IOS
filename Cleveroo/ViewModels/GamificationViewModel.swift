//
//  GamificationViewModel.swift
//  Cleveroo
//
//  Created by GitHub Copilot on 30/11/2025.
//

import Foundation
import Combine
import SwiftUI

class GamificationViewModel: ObservableObject {
    @Published var profile: GamificationProfile?
    @Published var leaderboard: [GamificationLeaderboardEntry] = []
    @Published var badges: [BadgeWithStatus] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let gamificationService = GamificationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Load My Profile (Child)
    func loadMyProfile(token: String) {
        isLoading = true
        errorMessage = nil
        
        gamificationService.getMyProfile(token: token)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur: \(error.localizedDescription)"
                        print("❌ Error loading profile: \(error)")
                    }
                },
                receiveValue: { [weak self] profile in
                    self?.profile = profile
                    print("✅ Profile loaded: Level \(profile.level), XP: \(profile.xp)")
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Load Child Profile (Parent)
    func loadChildProfile(childId: String, token: String) {
        isLoading = true
        errorMessage = nil
        
        gamificationService.getChildProfile(childId: childId, token: token)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur: \(error.localizedDescription)"
                        print("❌ Error loading child profile: \(error)")
                    }
                },
                receiveValue: { [weak self] profile in
                    self?.profile = profile
                    print("✅ Child profile loaded: Level \(profile.level)")
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Load Global Leaderboard
    func loadLeaderboard(token: String, limit: Int = 10) {
        isLoading = true
        errorMessage = nil
        
        gamificationService.getLeaderboard(limit: limit, token: token)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur: \(error.localizedDescription)"
                        print("❌ Error loading leaderboard: \(error)")
                    }
                },
                receiveValue: { [weak self] entries in
                    self?.leaderboard = entries
                    print("✅ Leaderboard loaded: \(entries.count) entries")
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Load Parent's Children Leaderboard
    func loadMyChildrenLeaderboard(token: String, limit: Int = 10) {
        isLoading = true
        errorMessage = nil
        
        gamificationService.getMyChildrenLeaderboard(limit: limit, token: token)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur: \(error.localizedDescription)"
                        print("❌ Error loading children leaderboard: \(error)")
                    }
                },
                receiveValue: { [weak self] entries in
                    self?.leaderboard = entries
                    print("✅ Children leaderboard loaded: \(entries.count) entries")
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Load My Badges (Child)
    func loadMyBadges(token: String) {
        isLoading = true
        errorMessage = nil
        
        gamificationService.getMyBadges(token: token)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur: \(error.localizedDescription)"
                        print("❌ Error loading badges: \(error)")
                    }
                },
                receiveValue: { [weak self] badges in
                    self?.badges = badges
                    let unlockedCount = badges.filter { $0.unlocked }.count
                    print("✅ Badges loaded: \(unlockedCount)/\(badges.count) unlocked")
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Load Child Badges (Parent)
    func loadChildBadges(childId: String, token: String) {
        isLoading = true
        errorMessage = nil
        
        gamificationService.getChildBadges(childId: childId, token: token)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur: \(error.localizedDescription)"
                        print("❌ Error loading child badges: \(error)")
                    }
                },
                receiveValue: { [weak self] badges in
                    self?.badges = badges
                    print("✅ Child badges loaded: \(badges.count) total")
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Properties
    var unlockedBadgesCount: Int {
        badges.filter { $0.unlocked }.count
    }
    
    var totalBadgesCount: Int {
        badges.count
    }
    
    var levelProgress: Double {
        profile?.progressToNextLevel ?? 0.0
    }
}
