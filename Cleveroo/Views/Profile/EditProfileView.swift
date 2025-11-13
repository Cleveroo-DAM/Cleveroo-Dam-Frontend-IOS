//
//  EditProfileView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/11/2025.
//

import SwiftUI

struct EditProfileView: View {
    
    // MARK: - State
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var animateButton = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showCheckmark = false
    @State private var checkmarkScale: CGFloat = 0.1
    @State private var isLoading = false
    
    // MARK: - Body
    var body: some View {
        ZStack {
            BubbleBackground()
                .ignoresSafeArea()
            
            VStack {
                ScrollView {
                    VStack(spacing: 25) {
                        
                        // MARK: Logo
                        Image("Cleveroo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .shadow(color: Color.white.opacity(0.8), radius: 10)
                            .padding(.top, 40)
                        
                        Text("Edit Your Profile")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        // MARK: Profile Fields
                        VStack(spacing: 15) {
                            if viewModel.isParent {
                                TextField("📧 Parent Email", text: $viewModel.parentEmail)
                                    .keyboardType(.emailAddress)
                                    .textFieldStyle(ChildFieldStyle())
                                
                                TextField("📱 Parent Phone", text: $viewModel.parentPhone)
                                    .keyboardType(.phonePad)
                                    .textFieldStyle(ChildFieldStyle())
                            } else {
                                TextField("👶 Child Username", text: $viewModel.childUsername)
                                    .textFieldStyle(ChildFieldStyle())
                                
                                HStack(spacing: 10) {
                                    GenderChoiceView(label: "👦 Boy", isSelected: viewModel.childGender == "👦 Boy") {
                                        viewModel.childGender = "👦 Boy"
                                    }
                                    GenderChoiceView(label: "👧 Girl", isSelected: viewModel.childGender == "👧 Girl") {
                                        viewModel.childGender = "👧 Girl"
                                    }
                                }
                                
                                TextField("🎂 Age", text: $viewModel.age)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(ChildFieldStyle())
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        // MARK: Save Button
                        Button(action: saveProfile) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "square.and.arrow.down.fill")
                                }
                                Text(isLoading ? "Saving..." : "Save Changes")
                            }
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [Color.cyan.opacity(0.7), Color.blue.opacity(0.6)],
                                                       startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 6)
                            .scaleEffect(animateButton ? 1.05 : 1.0)
                        }
                        .padding(.horizontal, 30)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: animateButton)
                    }
                    .padding(.vertical, 50)
                }
                
                Spacer()
            }
            
            // ✅ Animated Checkmark Overlay (Spring Bounce)
            if showCheckmark {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: 15) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                            .scaleEffect(checkmarkScale)
                            .animation(.spring(response: 0.5, dampingFraction: 0.45, blendDuration: 0.1), value: checkmarkScale)
                        
                        Text("Profile Updated!")
                            .font(.title3)
                            .foregroundColor(.white)
                            .bold()
                            .transition(.opacity)
                    }
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                }
                .transition(.opacity)
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK") {
                dismiss()
            }
        }
    }
    
    // MARK: - Actions
    private func saveProfile() {
        animateButton = true
        isLoading = true
        
        viewModel.updateProfile { success, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateButton = false
                isLoading = false
                
                if success {
                    withAnimation {
                        showCheckmark = true
                        checkmarkScale = 1.2
                    }
                    // Rebond du checkmark
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.3)) {
                            checkmarkScale = 1.0
                        }
                    }
                    
                    // Masquer après 1,5 sec + alerte
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showCheckmark = false
                        }
                        alertMessage = "✅ Profile updated successfully!"
                        showAlert = true
                    }
                } else {
                    alertMessage = error ?? "❌ Failed to update profile. Please try again."
                    showAlert = true
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    EditProfileView(viewModel: AuthViewModel())
}

