//
//  AIGameResultView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 24/11/2025.
//

import SwiftUI

struct AIGameResultView: View {
    let report: PersonalityResult
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header de félicitations
                    celebrationHeader
                    
                    // Métriques de performance
                    if let metrics = report.metrics {
                        performanceSection(metrics: metrics)
                    }
                    
                    // Scores de personnalité
                    if let scores = report.scores {
                        personalitySection(scores: scores)
                    }
                    
                    // Rapport AI (si disponible)
                    if let aiReport = report.report?.text {
                        aiReportSection(report: aiReport)
                    }
                    
                    // Boutons d'action
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("Résultats")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        onDismiss()
                    }
                }
            }
        }
    }
    
    private var celebrationHeader: some View {
        VStack(spacing: 16) {
            // Animation de confettis (simulée)
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            Text("Bravo !")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(.primary)
            
            Text("Tu as terminé le jeu avec succès !")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
    
    private func performanceSection(metrics: GameMetrics) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ta Performance")
                .font(.title2.weight(.semibold))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                if let accuracy = metrics.accuracy {
                    MetricCard(
                        title: "Précision",
                        value: "\(Int(accuracy * 100))%",
                        icon: "target",
                        color: accuracy > 0.8 ? .green : accuracy > 0.6 ? .orange : .red
                    )
                }
                
                if let totalAnswers = metrics.totalAnswers {
                    MetricCard(
                        title: "Questions",
                        value: "\(totalAnswers)",
                        icon: "questionmark.circle.fill",
                        color: .blue
                    )
                }
                
                if let meanRT = metrics.meanRT {
                    MetricCard(
                        title: "Temps moyen",
                        value: String(format: "%.1fs", meanRT / 1000),
                        icon: "stopwatch",
                        color: .purple
                    )
                }
                
                if let correct = metrics.correct {
                    MetricCard(
                        title: "Bonnes réponses",
                        value: "\(correct)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func personalitySection(scores: PersonalityScores) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Traits de Personnalité")
                .font(.title2.weight(.semibold))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                if let attention = scores.attention {
                    TraitBar(name: "Attention", score: attention, color: .blue)
                }
                
                if let creativity = scores.creativity {
                    TraitBar(name: "Créativité", score: creativity, color: .orange)
                }
                
                if let conscientiousness = scores.conscientiousness {
                    TraitBar(name: "Conscience", score: conscientiousness, color: .green)
                }
                
                if let openness = scores.openness {
                    TraitBar(name: "Ouverture", score: openness, color: .purple)
                }
                
                if let impulsivity = scores.impulsivity {
                    TraitBar(name: "Impulsivité", score: impulsivity, color: .red)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func aiReportSection(report: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.blue)
                Text("Analyse IA")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.primary)
            }
            
            Text(report)
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: onDismiss) {
                Text("Retour aux jeux")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            
            Button("Partager avec les parents") {
                // Action pour partager les résultats
            }
            .font(.subheadline)
            .foregroundColor(.blue)
        }
        .padding(.top, 20)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title.weight(.bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct TraitBar: View {
    let name: String
    let score: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text("\(score)/100")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(score) / 100, height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut(duration: 1), value: score)
                }
            }
            .frame(height: 8)
        }
    }
}

#Preview {
    AIGameResultView(
        report: PersonalityResult(
            scores: PersonalityScores(
                attention: 85,
                impulsivity: 45,
                conscientiousness: 78,
                openness: 92,
                creativity: 88,
                extraversion: nil,
                agreeableness: nil,
                neuroticism: nil
            ),
            metrics: GameMetrics(
                totalAnswers: 12,
                correct: 10,
                accuracy: 0.83,
                meanRT: 1250
            ),
            report: AIReport(
                text: "Cet enfant montre une excellente capacité d'attention et une grande créativité. Il serait bénéfique de continuer à encourager ces traits through des activités stimulantes."
            )
        ),
        onDismiss: {}
    )
}
