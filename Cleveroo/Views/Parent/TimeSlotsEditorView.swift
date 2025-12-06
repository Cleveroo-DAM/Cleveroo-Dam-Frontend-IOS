//
//  TimeSlotsEditorView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 30/11/2025.
//

import SwiftUI

struct TimeSlotsEditorView: View {
    let childId: String
    let currentTimeSlots: [String]
    let onSave: ([String]) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var timeSlots: [TimeSlot] = []
    @State private var showingAddSlot = false
    
    struct TimeSlot: Identifiable {
        let id = UUID()
        var startHour: Int = 8
        var startMinute: Int = 0
        var endHour: Int = 20
        var endMinute: Int = 0
        
        var formattedString: String {
            String(format: "%02d:%02d-%02d:%02d", startHour, startMinute, endHour, endMinute)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.97, blue: 0.98)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Plages horaires autorisées", systemImage: "clock.fill")
                                .font(.headline)
                            Text("Définissez les horaires pendant lesquels l'enfant peut utiliser l'application")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // Time Slots List
                        if timeSlots.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "clock.badge.questionmark")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("Aucune plage horaire définie")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("L'enfant peut utiliser l'app à tout moment")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                            .background(Color.white)
                            .cornerRadius(12)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(timeSlots.indices, id: \.self) { index in
                                    timeSlotRow(for: $timeSlots[index], at: index)
                                }
                            }
                        }
                        
                        // Add Button
                        Button(action: {
                            showingAddSlot = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Ajouter une plage horaire")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                        }
                        
                        // Save Button
                        Button(action: saveTimeSlots) {
                            Text("Enregistrer")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Plages horaires")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadCurrentTimeSlots()
            }
            .sheet(isPresented: $showingAddSlot) {
                AddTimeSlotView { newSlot in
                    timeSlots.append(newSlot)
                }
            }
        }
    }
    
    private func timeSlotRow(for slot: Binding<TimeSlot>, at index: Int) -> some View {
        HStack {
            Image(systemName: "clock")
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(slot.wrappedValue.formattedString)
                    .font(.headline)
                Text("De \(slot.wrappedValue.startHour):\(String(format: "%02d", slot.wrappedValue.startMinute)) à \(slot.wrappedValue.endHour):\(String(format: "%02d", slot.wrappedValue.endMinute))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                timeSlots.remove(at: index)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func loadCurrentTimeSlots() {
        timeSlots = currentTimeSlots.compactMap { slotString in
            let components = slotString.split(separator: "-")
            guard components.count == 2 else { return nil }
            
            let startComponents = components[0].split(separator: ":")
            let endComponents = components[1].split(separator: ":")
            
            guard startComponents.count == 2,
                  endComponents.count == 2,
                  let startHour = Int(startComponents[0]),
                  let startMinute = Int(startComponents[1]),
                  let endHour = Int(endComponents[0]),
                  let endMinute = Int(endComponents[1]) else {
                return nil
            }
            
            return TimeSlot(startHour: startHour, startMinute: startMinute, endHour: endHour, endMinute: endMinute)
        }
    }
    
    private func saveTimeSlots() {
        let formattedSlots = timeSlots.map { $0.formattedString }
        onSave(formattedSlots)
        dismiss()
    }
}

// MARK: - Add Time Slot View

struct AddTimeSlotView: View {
    let onAdd: (TimeSlotsEditorView.TimeSlot) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var startHour = 8
    @State private var startMinute = 0
    @State private var endHour = 20
    @State private var endMinute = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section("Heure de début") {
                    HStack {
                        Picker("Heure", selection: $startHour) {
                            ForEach(0..<24) { hour in
                                Text(String(format: "%02d", hour)).tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        
                        Text(":")
                        
                        Picker("Minute", selection: $startMinute) {
                            ForEach([0, 15, 30, 45], id: \.self) { minute in
                                Text(String(format: "%02d", minute)).tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }
                
                Section("Heure de fin") {
                    HStack {
                        Picker("Heure", selection: $endHour) {
                            ForEach(0..<24) { hour in
                                Text(String(format: "%02d", hour)).tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        
                        Text(":")
                        
                        Picker("Minute", selection: $endMinute) {
                            ForEach([0, 15, 30, 45], id: \.self) { minute in
                                Text(String(format: "%02d", minute)).tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }
            }
            .navigationTitle("Nouvelle plage horaire")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        let newSlot = TimeSlotsEditorView.TimeSlot(
                            startHour: startHour,
                            startMinute: startMinute,
                            endHour: endHour,
                            endMinute: endMinute
                        )
                        onAdd(newSlot)
                        dismiss()
                    }
                    .disabled(isInvalid)
                }
            }
        }
    }
    
    private var isInvalid: Bool {
        let startTime = startHour * 60 + startMinute
        let endTime = endHour * 60 + endMinute
        return endTime <= startTime
    }
}

#Preview {
    TimeSlotsEditorView(
        childId: "test",
        currentTimeSlots: ["08:00-12:00", "14:00-18:00"],
        onSave: { _ in }
    )
}
