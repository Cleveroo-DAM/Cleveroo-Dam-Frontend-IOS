//
//  ParentReportsDashboardView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/12/2025.
//
//  EXEMPLE D'INTÉGRATION - Ajoutez ce code dans votre interface parent

import SwiftUI

/// Vue exemple montrant comment intégrer les rapports dans l'interface parent
struct ParentReportsDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var reportViewModel = AIReportViewModel()
    
    let children: [Child]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // En-tête
                    headerSection
                    
                    // Aperçu rapide des derniers rapports
                    quickReportsPreview
                    
                    // Bouton pour voir tous les rapports
                    NavigationLink(destination: ReportsListView(
                        token: authViewModel.currentUserToken ?? "",
                        children: children
                    )) {
                        seeAllReportsButton
                    }
                    
                    // Section génération rapide
                    quickGenerateSection
                }
                .padding()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        .navigationTitle("📊 Rapports")
        .onAppear {
            if let token = authViewModel.currentUserToken {
                reportViewModel.fetchReports(token: token)
            }
        }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rapports de progression")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Suivez l'évolution de vos enfants avec l'analyse AI")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var quickReportsPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                Text("Derniers rapports")
                    .font(.headline)
                
                Spacer()
                
                if reportViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if reportViewModel.reports.isEmpty {
                emptyReportsCard
            } else {
                ForEach(reportViewModel.reports.prefix(3)) { report in
                    NavigationLink(destination: ReportDetailView(
                        report: report,
                        token: authViewModel.currentUserToken ?? ""
                    )) {
                        CompactReportCard(report: report)
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
    
    private var emptyReportsCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Aucun rapport disponible")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Générez votre premier rapport ci-dessous")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
    
    private var seeAllReportsButton: some View {
        HStack {
            Text("Voir tous les rapports")
                .font(.headline)
                .foregroundColor(.blue)
            
            Spacer()
            
            Image(systemName: "arrow.right.circle.fill")
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var quickGenerateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text("Génération rapide")
                    .font(.headline)
            }
            
            Text("Générez un rapport en un clic pour chaque enfant")
                .font(.caption)
                .foregroundColor(.gray)
            
            ForEach(children) { child in
                QuickGenerateRow(
                    child: child,
                    reportViewModel: reportViewModel,
                    token: authViewModel.currentUserToken ?? ""
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Compact Report Card
struct CompactReportCard: View {
    let report: Report
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar de l'enfant
            if let avatarURL = report.childId.avatar, let url = URL(string: avatarURL) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Circle().fill(Color.gray.opacity(0.3))
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(report.childId.username.prefix(1)).uppercased())
                            .font(.title3)
                            .foregroundColor(.blue)
                    )
            }
            
            // Info du rapport
            VStack(alignment: .leading, spacing: 4) {
                Text(report.childId.username)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(report.periodDisplayName)
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
            
            VStack {
                Text(report.performanceEmoji)
                    .font(.title2)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
}

// MARK: - Quick Generate Row
struct QuickGenerateRow: View {
    let child: Child
    @ObservedObject var reportViewModel: AIReportViewModel
    let token: String
    
    @State private var isGenerating = false
    @State private var selectedPeriod: String = "weekly"
    @State private var showSuccess = false
    
    var body: some View {
        HStack {
            // Avatar
            if let avatarURL = child.avatarURL, let url = URL(string: avatarURL) {
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
                        Text(String(child.username.prefix(1)).uppercased())
                            .font(.headline)
                            .foregroundColor(.blue)
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(child.username)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Picker("", selection: $selectedPeriod) {
                    Text("📅 Quotidien").tag("daily")
                    Text("📊 Hebdo").tag("weekly")
                    Text("📈 Mensuel").tag("monthly")
                }
                .pickerStyle(MenuPickerStyle())
                .font(.caption)
            }
            
            Spacer()
            
            if showSuccess {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Créé!")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            } else {
                Button(action: generateReport) {
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Générer")
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(8)
                    }
                }
                .disabled(isGenerating)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
    
    private func generateReport() {
        guard let childId = child.id else { return }
        
        isGenerating = true
        reportViewModel.generateReport(childId: childId, period: selectedPeriod, token: token) { success in
            isGenerating = false
            if success {
                showSuccess = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showSuccess = false
                }
            }
        }
    }
}

// MARK: - Preview
struct ParentReportsDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ParentReportsDashboardView(children: [])
            .environmentObject(AuthViewModel())
    }
}
