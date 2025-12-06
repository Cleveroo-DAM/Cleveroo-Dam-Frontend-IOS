//
//  ChildReportView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/12/2025.
//

import SwiftUI

struct ChildReportView: View {
    let child: Child
    let token: String
    
    @StateObject private var viewModel = AIReportViewModel()
    @State private var selectedPeriod: String = "weekly"
    @State private var showGenerateSuccess = false
    @Environment(\.dismiss) var dismiss
    
    let periods = [
        ("daily", "📅 Quotidien", "Rapport des dernières 24h"),
        ("weekly", "📊 Hebdomadaire", "Rapport des 7 derniers jours"),
        ("monthly", "📈 Mensuel", "Rapport des 30 derniers jours")
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header avec info de l'enfant
                    childHeaderCard
                    
                    // Section de génération de rapport
                    generateReportSection
                    
                    // Liste des rapports existants
                    if viewModel.isLoading {
                        ProgressView("Chargement des rapports...")
                            .padding()
                    } else if viewModel.reports.isEmpty {
                        emptyReportsView
                    } else {
                        existingReportsSection
                    }
                }
                .padding()
            }
        }
        .navigationTitle("📊 Rapports")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchReports(token: token, childId: child.id)
        }
        .alert("Erreur", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.clearError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .overlay(
            Group {
                if showGenerateSuccess {
                    successOverlay
                }
            }
        )
    }
    
    // MARK: - Child Header Card
    private var childHeaderCard: some View {
        HStack(spacing: 16) {
            // Avatar
            if let avatarURL = child.avatarURL, let url = URL(string: avatarURL) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Circle().fill(Color.blue.opacity(0.2))
                }
                .frame(width: 70, height: 70)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .overlay(
                        Text(String(child.username.prefix(1)).uppercased())
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(child.username)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(child.age) ans")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Image(systemName: "chart.bar.doc.horizontal.fill")
                        .font(.caption)
                    Text("\(viewModel.reports.count) rapport(s)")
                        .font(.caption)
                }
                .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Generate Report Section
    private var generateReportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text("Générer un nouveau rapport")
                    .font(.headline)
            }
            
            Text("Sélectionnez la période du rapport à générer")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Period Selection
            VStack(spacing: 12) {
                ForEach(periods, id: \.0) { period in
                    Button(action: { selectedPeriod = period.0 }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(period.1)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(period.2)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if selectedPeriod == period.0 {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray.opacity(0.3))
                                    .font(.title2)
                            }
                        }
                        .padding()
                        .background(
                            selectedPeriod == period.0
                            ? Color.blue.opacity(0.1)
                            : Color.gray.opacity(0.05)
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    selectedPeriod == period.0
                                    ? Color.blue
                                    : Color.clear,
                                    lineWidth: 2
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Generate Button
            Button(action: generateReport) {
                HStack {
                    if viewModel.isGenerating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Génération en cours...")
                    } else {
                        Image(systemName: "sparkles")
                        Text("Générer le rapport")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .disabled(viewModel.isGenerating)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Empty Reports View
    private var emptyReportsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 70))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Aucun rapport disponible")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Générez votre premier rapport pour suivre la progression de \(child.username)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Existing Reports Section
    private var existingReportsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                Text("Rapports générés")
                    .font(.headline)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.reports) { report in
                    NavigationLink(destination: ReportDetailView(report: report, token: token)) {
                        ReportRowCard(report: report)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Success Overlay
    private var successOverlay: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Rapport généré avec succès!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Le rapport a été créé et ajouté à la liste")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.3), radius: 20)
        .transition(.scale.combined(with: .opacity))
    }
    
    // MARK: - Actions
    private func generateReport() {
        guard let childId = child.id else { return }
        
        viewModel.generateReport(childId: childId, period: selectedPeriod, token: token) { success in
            if success {
                withAnimation(.spring()) {
                    showGenerateSuccess = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.spring()) {
                        showGenerateSuccess = false
                    }
                }
            }
        }
    }
}

// MARK: - Report Row Card
struct ReportRowCard: View {
    let report: Report
    
    var body: some View {
        HStack(spacing: 12) {
            // Period Icon
            Circle()
                .fill(periodColor.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: periodIcon)
                        .font(.title3)
                        .foregroundColor(periodColor)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(report.periodDisplayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(report.formattedDateRange)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 8) {
                    Label("\(report.overallAverageScore)%", systemImage: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    
                    Label("\(report.totalActivities)", systemImage: "gamecontroller.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(report.performanceEmoji)
                    .font(.title)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var periodColor: Color {
        switch report.period {
        case "daily": return .green
        case "weekly": return .blue
        case "monthly": return .orange
        default: return .gray
        }
    }
    
    private var periodIcon: String {
        switch report.period {
        case "daily": return "calendar"
        case "weekly": return "calendar.badge.clock"
        case "monthly": return "calendar.badge.plus"
        default: return "calendar"
        }
    }
}

struct ChildReportView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChildReportView(
                child: Child(id: "1", username: "Alice", age: 8),
                token: "dummy-token"
            )
        }
    }
}
