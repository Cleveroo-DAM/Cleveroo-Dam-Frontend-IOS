//
//  AddChildView.swift
//  Cleveroo
//
//  Form to add a child to parent's account
//

import SwiftUI

struct AddChildView: View {
    @ObservedObject var viewModel: AuthViewModel
    var onSuccess: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    @State private var username = ""
    @State private var age = ""
    @State private var gender = "male"
    @State private var showContent = false
    @State private var animateButton = false
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                BubbleBackground().ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        VStack(spacing: 12) {
                            Image("Cleveroo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .shadow(color: Color.white.opacity(0.8), radius: 20)
                            
                            Text("Add a Child 👶")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text("Create an account for your child")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 30)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : -20)
                        
                        // MARK: Child Info Fields
                        VStack(spacing: 14) {
                            TextField("👶 Username", text: $username)
                                .autocapitalization(.none)
                                .textFieldStyle(ChildFieldStyle())
                            
                            TextField("🎂 Age", text: $age)
                                .keyboardType(.numberPad)
                                .textFieldStyle(ChildFieldStyle())
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("👧 Gender")
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.leading, 5)
                                
                                HStack(spacing: 10) {
                                    GenderButton(label: "👦 Boy", value: "male", isSelected: gender == "male") {
                                        gender = "male"
                                    }
                                    
                                    GenderButton(label: "👧 Girl", value: "female", isSelected: gender == "female") {
                                        gender = "female"
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        
                        // MARK: Info Text
                        Text("💡 The child will use the same password as the parent account")
                            .font(.caption)
                            .foregroundColor(.yellow.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .opacity(showContent ? 1 : 0)
                        
                        // MARK: Error
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        
                        // MARK: Add Button
                        Button(action: addChildAction) {
                            Text(viewModel.isLoading ? "Adding Child..." : "✨ Add Child ✨")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(colors: [Color.purple, Color.pink.opacity(0.9)],
                                                           startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                                .shadow(radius: 6)
                                .scaleEffect(animateButton ? 1.05 : 1.0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: animateButton)
                        }
                        .disabled(viewModel.isLoading)
                        .padding(.horizontal)
                        .opacity(showContent ? 1 : 0)
                        
                        // MARK: Cancel Button
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                                .font(.footnote)
                                .foregroundColor(.yellow)
                        }
                        .padding(.top, 10)
                        .opacity(showContent ? 1 : 0)
                    }
                    .padding(.bottom, 60)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showContent = true
                }
            }
            .alert("Success!", isPresented: $showSuccessAlert) {
                Button("OK") {
                    showSuccessAlert = false
                    onSuccess()
                    dismiss()
                }
            } message: {
                Text("Child account created successfully! An email has been sent to the parent.")
            }
            .alert("Validation Error", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationMessage)
            }
        }
    }
    
    private func addChildAction() {
        // Validation
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            validationMessage = "Please enter a username"
            showValidationAlert = true
            return
        }
        
        guard !age.isEmpty, let ageInt = Int(age), ageInt > 0, ageInt < 18 else {
            validationMessage = "Please enter a valid age (1-17)"
            showValidationAlert = true
            return
        }
        
        // If validation OK, proceed with adding child
        animateButton = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            animateButton = false
            
            viewModel.addChild(username: username, age: ageInt, gender: gender) { success, error in
                if success {
                    showSuccessAlert = true
                } else {
                    validationMessage = error ?? "Failed to add child"
                    showValidationAlert = true
                }
            }
        }
    }
}

// MARK: - Gender Button Component
struct GenderButton: View {
    let label: String
    let value: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.15))
                .cornerRadius(15)
                .overlay(RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.white.opacity(0.8) : Color.white.opacity(0.3), lineWidth: 1))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    AddChildView(viewModel: AuthViewModel(), onSuccess: {})
}
