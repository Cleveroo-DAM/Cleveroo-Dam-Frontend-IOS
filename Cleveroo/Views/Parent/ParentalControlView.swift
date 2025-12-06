//
//  ParentalControlView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 30/11/2025.
//

import SwiftUI

struct ParentalControlView: View {
    let child: Child
    @StateObject private var viewModel = ParentalControlViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var showBlockDialog = false
    @State private var blockReason = ""
    @State private var showTimeSlotsEditor = false
    @State private var showScreenTimeLimitEditor = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.97, blue: 0.98)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Chargement...")
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Child Info Header
                            childInfoHeader
                            
                            // Block/Unblock Section
                            blockControlSection
                            
                            // Time Slots Section
                            timeSlotsSection
                            
                            // Screen Time Limit Section
                            screenTimeLimitSection
                            
                            // Screen Time Today
                            screenTimeTodaySection
                            
                            // Screen Time Weekly
                            screenTimeWeeklySection
                            
                            // Screen Time History
                            screenTimeHistorySection
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Contrôle Parental")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
            .task {
                if let childId = child.id {
                    await viewModel.loadParentalControl(for: childId)
                    await viewModel.loadScreenTime(for: childId)
                    await viewModel.loadScreenTimeHistory(for: childId)
                }
            }
            .alert("Bloquer l'accès", isPresented: $showBlockDialog) {
                TextField("Raison (optionnel)", text: $blockReason)
                Button("Annuler", role: .cancel) { }
                Button("Bloquer", role: .destructive) {
                    Task {
                        if let childId = child.id {
                            await viewModel.blockChild(childId, reason: blockReason.isEmpty ? nil : blockReason)
                        }
                    }
                }
            } message: {
                Text("Voulez-vous bloquer l'accès de \(child.username) ?")
            }
            .sheet(isPresented: $showTimeSlotsEditor) {
                if let childId = child.id {
                    TimeSlotsEditorView(
                        childId: childId,
                        currentTimeSlots: viewModel.parentalControl?.allowedTimeSlots ?? [],
                        onSave: { timeSlots in
                            Task {
                                await viewModel.updateTimeSlots(childId, timeSlots: timeSlots)
                            }
                        }
                    )
                }
            }
            .sheet(isPresented: $showScreenTimeLimitEditor) {
                if let childId = child.id {
                    ScreenTimeLimitEditorView(
                        childId: childId,
                        currentLimit: viewModel.parentalControl?.dailyScreenTimeLimit,
                        onSave: { limit in
                            Task {
                                await viewModel.updateScreenTimeLimit(childId, limitMinutes: limit)
                            }
                        }
                    )
                }
            }
        }
    }
    
    private var childInfoHeader: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: child.avatarURL ?? "")) { image in
                image.resizable()
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(child.username)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(child.age) ans")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var blockControlSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Blocage Manuel", systemImage: "hand.raised.slash.fill")
                .font(.headline)
            
            if let control = viewModel.parentalControl {
                if control.isBlocked == true {
                    // État bloqué - Afficher en rouge avec bouton vert pour débloquer
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "xmark.shield.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.red)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Accès Bloqué")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                
                                if let reason = control.blockReason, !reason.isEmpty {
                                    Text(reason)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        
                        Button(action: {
                            Task {
                                if let childId = child.id {
                                    await viewModel.unblockChild(childId)
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                Text("Débloquer l'accès")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.green, Color.green.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.green.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                    }
                } else {
                    // État débloqué - Afficher en vert avec bouton rouge pour bloquer
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Accès Autorisé")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                
                                Text("L'enfant peut utiliser l'application")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                        
                        Button(action: {
                            showBlockDialog = true
                        }) {
                            HStack {
                                Image(systemName: "hand.raised.slash.fill")
                                    .font(.system(size: 18))
                                Text("Bloquer l'accès immédiatement")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.red, Color(red: 0.8, green: 0.2, blue: 0.2)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.red.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var timeSlotsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Plages horaires autorisées", systemImage: "clock.badge.checkmark")
                .font(.headline)
            
            if let timeSlots = viewModel.parentalControl?.allowedTimeSlots, !timeSlots.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(timeSlots, id: \.self) { slot in
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 16))
                            Text(slot)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 14))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(8)
                    }
                }
            } else {
                HStack {
                    Image(systemName: "clock.badge.exclamationmark")
                        .foregroundColor(.orange)
                        .font(.system(size: 20))
                    Text("Aucune restriction horaire - L'enfant peut utiliser l'app à tout moment")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.05))
                .cornerRadius(8)
            }
            
            Button(action: {
                showTimeSlotsEditor = true
            }) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 16))
                    Text("Modifier les plages horaires")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var screenTimeLimitSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Limite de temps d'écran quotidien", systemImage: "hourglass.circle")
                .font(.headline)
            
            if let limit = viewModel.parentalControl?.dailyScreenTimeLimit, limit > 0 {
                HStack {
                    Image(systemName: "hourglass.bottomhalf.filled")
                        .foregroundColor(.orange)
                        .font(.system(size: 20))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(limit) minutes par jour")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("\(limit / 60)h \(limit % 60)m - Limite atteinte = Blocage automatique")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 16))
                }
                .padding()
                .background(Color.orange.opacity(0.05))
                .cornerRadius(8)
            } else {
                HStack {
                    Image(systemName: "infinity.circle")
                        .foregroundColor(.purple)
                        .font(.system(size: 20))
                    Text("Aucune limite - Temps d'écran illimité")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.purple.opacity(0.05))
                .cornerRadius(8)
            }
            
            Button(action: {
                showScreenTimeLimitEditor = true
            }) {
                HStack {
                    Image(systemName: "hourglass.badge.plus")
                        .font(.system(size: 16))
                    Text("Modifier la limite")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange.opacity(0.1))
                .foregroundColor(.orange)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var screenTimeTodaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Temps d'écran aujourd'hui", systemImage: "clock.fill")
                .font(.headline)
            
            if let screenTime = viewModel.screenTimeData {
                VStack(spacing: 16) {
                    // Affichage du temps total
                    HStack(spacing: 20) {
                        VStack(alignment: .center, spacing: 8) {
                            Text("\(screenTime.hours)h \(screenTime.minutes)m")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text("Temps total")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        
                        Spacer()
                        
                        // Barre de progression par rapport à la limite
                        if let limit = viewModel.parentalControl?.dailyScreenTimeLimit, limit > 0 {
                            VStack(alignment: .trailing, spacing: 8) {
                                let percentage = Double(screenTime.totalMinutes) / Double(limit) * 100
                                Text(String(format: "%.0f%%", percentage))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(percentage > 80 ? .red : .green)
                                
                                ProgressView(value: Double(screenTime.totalMinutes), total: Double(limit))
                                    .frame(width: 120)
                                
                                Text("\(screenTime.totalMinutes)/\(limit) min")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            } else {
                Text("Aucune donnée disponible")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var screenTimeWeeklySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Temps d'écran - Semaine", systemImage: "chart.bar.fill")
                .font(.headline)
            
            if !viewModel.screenTimeHistory.isEmpty {
                VStack(spacing: 12) {
                    // Statistiques résumées
                    HStack(spacing: 12) {
                        // Temps total de la semaine
                        VStack(alignment: .center, spacing: 6) {
                            Text("\(calculateWeeklyTotal())")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text("Total")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        
                        // Moyenne quotidienne
                        VStack(alignment: .center, spacing: 6) {
                            Text("\(calculateDailyAverage())")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Moyenne/jour")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                        
                        // Pic de la semaine
                        VStack(alignment: .center, spacing: 6) {
                            Text("\(calculatePeakDay())")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            Text("Pic/jour")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Détail par jour
                    VStack(spacing: 8) {
                        ForEach(viewModel.screenTimeHistory) { entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(formatDateForDay(entry.date))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text("\(entry.sessionsCount) session(s)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // Barre visuelle
                                let maxMinutes = viewModel.screenTimeHistory.map { $0.totalMinutes }.max() ?? 60
                                GeometryReader { geometry in
                                    HStack(spacing: 4) {
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.gray.opacity(0.2))
                                            
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(getColorForScreenTime(entry.totalMinutes))
                                                .frame(width: geometry.size.width * CGFloat(entry.totalMinutes) / CGFloat(maxMinutes))
                                        }
                                        .frame(height: 20)
                                        
                                        Text("\(entry.totalMinutes) min")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(height: 20)
                            }
                        }
                    }
                }
            } else {
                Text("Aucune donnée disponible pour cette semaine")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func calculateWeeklyTotal() -> String {
        let totalMinutes = viewModel.screenTimeHistory.reduce(0) { $0 + $1.totalMinutes }
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return "\(hours)h \(minutes)m"
    }
    
    private func calculateDailyAverage() -> String {
        guard !viewModel.screenTimeHistory.isEmpty else { return "0m" }
        let totalMinutes = viewModel.screenTimeHistory.reduce(0) { $0 + $1.totalMinutes }
        let average = totalMinutes / viewModel.screenTimeHistory.count
        return "\(average)m"
    }
    
    private func calculatePeakDay() -> String {
        let peakMinutes = viewModel.screenTimeHistory.map { $0.totalMinutes }.max() ?? 0
        let hours = peakMinutes / 60
        let minutes = peakMinutes % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(peakMinutes)m"
    }
    
    private func formatDateForDay(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = formatter.date(from: dateString) {
            let calendar = Calendar.current
            let today = Date()
            
            if calendar.isDateInToday(date) {
                return "Aujourd'hui"
            } else if calendar.isDateInYesterday(date) {
                return "Hier"
            } else {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "EEEE dd MMM"
                displayFormatter.locale = Locale(identifier: "fr_FR")
                return displayFormatter.string(from: date)
            }
        }
        return dateString
    }
    
    private func getColorForScreenTime(_ minutes: Int) -> Color {
        if minutes < 30 {
            return .green
        } else if minutes < 60 {
            return .yellow
        } else if minutes < 120 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var screenTimeHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Tendances et alertes", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
            
            if !viewModel.screenTimeHistory.isEmpty {
                VStack(spacing: 12) {
                    // Alerte si dépassement
                    if let todayData = viewModel.screenTimeData,
                       let limit = viewModel.parentalControl?.dailyScreenTimeLimit,
                       todayData.totalMinutes > limit {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 20))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("⚠️ Limite atteinte aujourd'hui")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                                
                                Text("L'enfant a dépassé la limite quotidienne")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Tendance à la hausse/baisse
                    if viewModel.screenTimeHistory.count >= 2 {
                        let lastDay = viewModel.screenTimeHistory.first?.totalMinutes ?? 0
                        let previousDay = viewModel.screenTimeHistory.count > 1 ? viewModel.screenTimeHistory[1].totalMinutes : 0
                        let trend = lastDay - previousDay
                        
                        HStack {
                            Image(systemName: trend > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                .foregroundColor(trend > 0 ? .orange : .green)
                                .font(.system(size: 20))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tendance")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text(trend > 0 ? "Usage en hausse de \(trend) min" : "Usage en baisse de \(-trend) min")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            } else {
                Text("Aucune donnée d'historique disponible")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}
