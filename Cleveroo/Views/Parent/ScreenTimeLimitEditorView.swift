//
//  ScreenTimeLimitEditorView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 30/11/2025.
//

import SwiftUI

struct ScreenTimeLimitEditorView: View {
    let childId: String
    let currentLimit: Int?
    let onSave: (Int) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var hours: Int = 2
    @State private var minutes: Int = 0
    @State private var noLimit: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.97, blue: 0.98)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Limite de temps d'écran", systemImage: "hourglass")
                                .font(.headline)
                            Text("Définissez le temps maximum que l'enfant peut passer sur l'application par jour")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // No Limit Toggle
                        Toggle(isOn: $noLimit) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Aucune limite")
                                    .font(.headline)
                                Text("L'enfant peut utiliser l'app sans restriction de temps")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        if !noLimit {
                            // Time Picker
                            VStack(spacing: 16) {
                                Text("Temps autorisé par jour")
                                    .font(.headline)
                                
                                HStack(spacing: 30) {
                                    // Hours Picker
                                    VStack {
                                        Picker("Heures", selection: $hours) {
                                            ForEach(0..<13) { hour in
                                                Text("\(hour)").tag(hour)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 80)
                                        
                                        Text("heures")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    // Minutes Picker
                                    VStack {
                                        Picker("Minutes", selection: $minutes) {
                                            ForEach([0, 15, 30, 45], id: \.self) { minute in
                                                Text("\(minute)").tag(minute)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 80)
                                        
                                        Text("minutes")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                // Total in minutes
                                Text("Total: \(totalMinutes) minutes par jour")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            
                            // Suggestions
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Suggestions")
                                    .font(.headline)
                                
                                HStack {
                                    suggestionButton("30 min", minutes: 30)
                                    suggestionButton("1 heure", minutes: 60)
                                    suggestionButton("2 heures", minutes: 120)
                                }
                                
                                HStack {
                                    suggestionButton("3 heures", minutes: 180)
                                    suggestionButton("4 heures", minutes: 240)
                                    suggestionButton("5 heures", minutes: 300)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // Save Button
                        Button(action: saveLimit) {
                            Text("Enregistrer")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(!noLimit && totalMinutes == 0)
                    }
                    .padding()
                }
            }
            .navigationTitle("Limite de temps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadCurrentLimit()
            }
        }
    }
    
    private var totalMinutes: Int {
        hours * 60 + minutes
    }
    
    private func suggestionButton(_ title: String, minutes: Int) -> some View {
        Button(action: {
            hours = minutes / 60
            self.minutes = minutes % 60
        }) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .foregroundColor(.orange)
                .cornerRadius(8)
        }
    }
    
    private func loadCurrentLimit() {
        if let limit = currentLimit, limit > 0 {
            hours = limit / 60
            minutes = limit % 60
            noLimit = false
        } else {
            noLimit = true
        }
    }
    
    private func saveLimit() {
        if noLimit {
            onSave(0) // 0 signifie pas de limite
        } else {
            onSave(totalMinutes)
        }
        dismiss()
    }
}

#Preview {
    ScreenTimeLimitEditorView(
        childId: "test",
        currentLimit: 120,
        onSave: { _ in }
    )
}
