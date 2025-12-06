//
//  ReportsListView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/12/2025.
//

import SwiftUI

struct ReportsListView: View {
    @StateObject private var viewModel = AIReportViewModel()
    @State private var showGenerateSheet = false
    @State private var selectedChildId: String = ""
    @State private var selectedPeriod: String = "weekly"
    
    let token: String
    let children: [Child] // List of children for parent
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Chargement des rapports...")
                        .scaleEffect(1.2)
                } else if viewModel.reports.isEmpty {
                    emptyStateView
                } else {
                    reportsList
                }
            }
            .navigationTitle("📊 Rapports")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showGenerateSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showGenerateSheet) {
                GenerateReportSheet(
                    viewModel: viewModel,
                    token: token,
                    children: children,
                    isPresented: $showGenerateSheet
                )
            }
            .onAppear {
                viewModel.fetchReports(token: token)
            }
            .alert("Erreur", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("Aucun rapport disponible")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Générez votre premier rapport pour suivre la progression de votre enfant")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showGenerateSheet = true }) {
                Label("Générer un rapport", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
            }
        }
    }
    
    private var reportsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.reports) { report in
                    NavigationLink(destination: ReportDetailView(report: report, token: token)) {
                        ReportCardView(report: report)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
}

// MARK: - Report Card View
struct ReportCardView: View {
    let report: Report
    @State private var imageLoadFailed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cover Image - Afficher seulement si disponible ET se charge avec succès
            if !imageLoadFailed, let coverImageUrl = report.coverImage, let url = URL(string: coverImageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .cornerRadius(12)
                            .clipped()
                    case .failure:
                        // Masquer silencieusement l'image en cas d'erreur
                        EmptyView()
                            .onAppear {
                                imageLoadFailed = true
                            }
                    case .empty:
                        // Placeholder discret pendant le chargement
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 120)
                            .cornerRadius(12)
                            .clipped()
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(report.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(report.formattedDateRange)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(report.performanceEmoji)
                    .font(.system(size: 40))
            }
            
            // Child Info
            HStack {
                if let avatarURL = report.childId.avatar, let url = URL(string: avatarURL) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Circle().fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(report.childId.username.prefix(1)).uppercased())
                                .font(.headline)
                                .foregroundColor(.blue)
                        )
                }
                
                VStack(alignment: .leading) {
                    Text(report.childId.username)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(report.periodDisplayName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
            
            // Summary
            Text(report.summary)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // Stats
            HStack(spacing: 20) {
                ReportStatBadge(icon: "star.fill", value: "\(report.overallAverageScore)%", label: "Score moyen")
                ReportStatBadge(icon: "chart.bar.fill", value: "\(report.totalActivities)", label: "Activités")
                ReportStatBadge(icon: "flame.fill", value: "\(report.xpGained)", label: "XP gagné")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct ReportStatBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Generate Report Sheet
struct GenerateReportSheet: View {
    @ObservedObject var viewModel: AIReportViewModel
    let token: String
    let children: [Child]
    @Binding var isPresented: Bool
    
    @State private var selectedChildId: String = ""
    @State private var selectedPeriod: String = "weekly"
    
    let periods = [
        ("daily", "📅 Quotidien", "Rapport des dernières 24h"),
        ("weekly", "📊 Hebdomadaire", "Rapport des 7 derniers jours"),
        ("monthly", "📈 Mensuel", "Rapport des 30 derniers jours")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sélectionner un enfant")) {
                    Picker("Enfant", selection: $selectedChildId) {
                        Text("Choisir...").tag("")
                        ForEach(children) { child in
                            Text(child.username).tag(child.id ?? "")
                        }
                    }
                }
                
                Section(header: Text("Période du rapport")) {
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
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: generateReport) {
                        if viewModel.isGenerating {
                            HStack {
                                ProgressView()
                                Text("Génération en cours...")
                            }
                        } else {
                            Text("Générer le rapport")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                        }
                    }
                    .disabled(selectedChildId.isEmpty || viewModel.isGenerating)
                }
            }
            .navigationTitle("Nouveau rapport")
            .navigationBarItems(trailing: Button("Fermer") {
                isPresented = false
            })
        }
    }
    
    private func generateReport() {
        viewModel.generateReport(childId: selectedChildId, period: selectedPeriod, token: token) { success in
            if success {
                isPresented = false
            }
        }
    }
}

struct ReportsListView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsListView(token: "dummy-token", children: [])
    }
}
