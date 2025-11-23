//
//  CompleteActivityView.swift
//  Cleveroo
//
//  Form for child to mark activity as completed
//

import SwiftUI

struct CompleteActivityView: View {
    let assignmentId: String
    @ObservedObject var activityVM: ActivityViewModel
    var onSuccess: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    @State private var score: Double = 50
    @State private var notes: String = ""
    @State private var showContent = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                BubbleBackground().ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 15) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.green)
                                .shadow(color: .green.opacity(0.5), radius: 10)
                            
                            Text("Complete Activity")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("How did you do?")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 30)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : -20)
                        
                        // Score Slider
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("Your Score")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 10) {
                                HStack {
                                    Spacer()
                                    Text("\(Int(score))%")
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                
                                Slider(value: $score, in: 0...100, step: 5)
                                    .accentColor(.yellow)
                                
                                HStack {
                                    Text("0%")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                    Spacer()
                                    Text("100%")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: showContent)
                        
                        // Notes Field
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(.cyan)
                                Text("Notes (Optional)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            TextEditor(text: $notes)
                                .frame(height: 120)
                                .padding(10)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(15)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            
                            Text("Share your thoughts or what you learned")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.leading, 5)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showContent)
                        
                        // Submit Button
                        Button(action: submitCompletion) {
                            HStack(spacing: 10) {
                                if activityVM.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                    Text("Submit Completion")
                                        .fontWeight(.bold)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.green, Color.cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: Color.green.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .disabled(activityVM.isLoading)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: showContent)
                        
                        // Cancel Button
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .opacity(showContent ? 1 : 0)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showContent = true
                }
            }
            .alert("Success! 🎉", isPresented: $showSuccessAlert) {
                Button("OK") {
                    onSuccess()
                }
            } message: {
                Text("Activity completed successfully!")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func submitCompletion() {
        let scoreInt = Int(score)
        let notesText = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalNotes = notesText.isEmpty ? nil : notesText
        
        activityVM.completeActivity(assignmentId: assignmentId, score: scoreInt, notes: finalNotes) { success, error in
            if success {
                showSuccessAlert = true
            } else {
                errorMessage = error ?? "Failed to complete activity"
                showErrorAlert = true
            }
        }
    }
}

#Preview {
    CompleteActivityView(assignmentId: "123", activityVM: ActivityViewModel(), onSuccess: {})
}
