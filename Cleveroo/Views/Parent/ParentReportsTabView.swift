//
//  ParentReportsTabView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/12/2025.
//

import SwiftUI

struct ParentReportsTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var reportViewModel = AIReportViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if reportViewModel.isLoading {
                    ProgressView("Chargement des rapports...")
                } else if authViewModel.childrenList.isEmpty {
                    emptyStateView
                } else {
                    childrenReportsView
                }
            }
            .navigationTitle("📊 Rapports des Enfants")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let token = authViewModel.currentUserToken {
                    reportViewModel.fetchReports(token: token)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Aucun enfant")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Ajoutez des enfants pour voir leurs rapports")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    private var childrenReportsView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(authViewModel.childrenList.indices, id: \.self) { index in
                    let childDict = authViewModel.childrenList[index]
                    if let childId = childDict["_id"] as? String,
                       let username = childDict["username"] as? String,
                       let age = childDict["age"] as? Int {
                        
                        let child = Child(id: childId, username: username, age: age)
                        
                        NavigationLink(destination: ChildReportView(
                            child: child,
                            token: authViewModel.currentUserToken ?? ""
                        )) {
                            ChildReportCard(
                                child: child,
                                reports: reportViewModel.reports.filter { $0.childId.id == childId }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Child Report Card
struct ChildReportCard: View {
    let child: Child
    let reports: [Report]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(child.username.prefix(1)).uppercased())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(child.username)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(child.age) ans")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(reports.count)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("rapport(s)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
            
            // Recent Reports
            if reports.isEmpty {
                Text("Aucun rapport généré")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Derniers rapports")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    
                    ForEach(reports.prefix(3)) { report in
                        HStack(spacing: 8) {
                            Image(systemName: "chart.bar.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(report.periodDisplayName)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                
                                Text(report.formattedDateRange)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text("\(report.overallAverageScore)%")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                
                                Text(report.performanceEmoji)
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct ParentReportsTabView_Previews: PreviewProvider {
    static var previews: some View {
        ParentReportsTabView()
            .environmentObject(AuthViewModel())
    }
}
