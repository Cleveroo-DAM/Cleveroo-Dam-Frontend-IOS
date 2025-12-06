//
//  RestrictionChecker.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 30/11/2025.
//

import Foundation

class RestrictionChecker {
    static let shared = RestrictionChecker()
    
    private init() {}
    
    /// Vérifier si l'heure actuelle est dans les plages horaires autorisées
    func isWithinAllowedTimeSlots(_ timeSlots: [String]) -> Bool {
        guard !timeSlots.isEmpty else {
            return true // Pas de restriction si aucune plage définie
        }
        
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentTime = currentHour * 60 + currentMinute // en minutes depuis minuit
        
        for slot in timeSlots {
            let components = slot.split(separator: "-")
            guard components.count == 2 else { continue }
            
            // Parse start time
            let startComponents = components[0].split(separator: ":")
            guard startComponents.count == 2,
                  let startHour = Int(startComponents[0]),
                  let startMinute = Int(startComponents[1]) else { continue }
            let startTime = startHour * 60 + startMinute
            
            // Parse end time
            let endComponents = components[1].split(separator: ":")
            guard endComponents.count == 2,
                  let endHour = Int(endComponents[0]),
                  let endMinute = Int(endComponents[1]) else { continue }
            let endTime = endHour * 60 + endMinute
            
            // Check if current time is within this slot
            if currentTime >= startTime && currentTime <= endTime {
                return true
            }
        }
        
        return false // Pas dans une plage autorisée
    }
    
    /// Formater les plages horaires pour l'affichage
    func formatTimeSlots(_ timeSlots: [String]) -> String {
        if timeSlots.isEmpty {
            return "Aucune restriction horaire"
        }
        return timeSlots.joined(separator: ", ")
    }
    
    /// Calculer le temps restant avant la prochaine plage horaire
    func timeUntilNextSlot(_ timeSlots: [String]) -> String? {
        guard !timeSlots.isEmpty else { return nil }
        
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentTime = currentHour * 60 + currentMinute
        
        var nextSlotTime: Int?
        
        for slot in timeSlots {
            let components = slot.split(separator: "-")
            guard components.count == 2 else { continue }
            
            let startComponents = components[0].split(separator: ":")
            guard startComponents.count == 2,
                  let startHour = Int(startComponents[0]),
                  let startMinute = Int(startComponents[1]) else { continue }
            let startTime = startHour * 60 + startMinute
            
            if startTime > currentTime {
                if nextSlotTime == nil || startTime < nextSlotTime! {
                    nextSlotTime = startTime
                }
            }
        }
        
        guard let nextTime = nextSlotTime else { return nil }
        
        let remainingMinutes = nextTime - currentTime
        let hours = remainingMinutes / 60
        let minutes = remainingMinutes % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) minutes"
        }
    }
    
    /// Vérifier si la limite de temps d'écran est dépassée
    func isScreenTimeLimitExceeded(usedMinutes: Int, limitMinutes: Int?) -> Bool {
        guard let limit = limitMinutes, limit > 0 else {
            return false // Pas de limite définie
        }
        return usedMinutes >= limit
    }
    
    /// Calculer le temps d'écran restant
    func remainingScreenTime(usedMinutes: Int, limitMinutes: Int?) -> String {
        guard let limit = limitMinutes, limit > 0 else {
            return "Illimité"
        }
        
        let remaining = max(0, limit - usedMinutes)
        let hours = remaining / 60
        let minutes = remaining % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) minutes"
        }
    }
}
