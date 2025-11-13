//
//  ProfileView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/11/2025.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                BubbleBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    Image("Cleveroo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .shadow(color: Color.white.opacity(0.8), radius: 10)
                        .padding(.top, 40)
                    
                    VStack(spacing: 12) {
                        Text(viewModel.selectedRole == "Parent" ? viewModel.parentEmail : viewModel.childUsername)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if viewModel.selectedRole == "Child" {
                            Text("Age: \(viewModel.age)")
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        Text("Role: \(viewModel.selectedRole)")
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple.opacity(0.25))
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.5), lineWidth: 1.5))
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    // ✨ Profile Actions
                                        VStack(spacing: 15) {
                                            Button(action: { showEditProfile.toggle() }) {
                                                HStack {
                                                    Image(systemName: "pencil.circle.fill")
                                                    Text("Edit Profile")
                                                }
                                                .fontWeight(.bold)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(LinearGradient(colors: [Color.cyan.opacity(0.7), Color.blue.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                                                .foregroundColor(.white)
                                                .clipShape(Capsule())
                                                .shadow(radius: 5)
                                            }
                                            .padding(.horizontal, 40)
                                            .sheet(isPresented: $showEditProfile) {
                                                EditProfileView()
                                            }
                                            
                                            Button(action: { showChangePassword.toggle() }) {
                                                HStack {
                                                    Image(systemName: "key.fill")
                                                    Text("Change Password")
                                                }
                                                .fontWeight(.bold)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(LinearGradient(colors: [Color.purple, Color.pink.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                                                .foregroundColor(.white)
                                                .clipShape(Capsule())
                                                .shadow(radius: 5)
                                            }
                                            .padding(.horizontal, 40)
                                            .sheet(isPresented: $showChangePassword) {
                                                ResetPasswordView(email: viewModel.selectedRole == "Parent" ? viewModel.parentEmail : viewModel.childUsername)
                                            }
                                            
                                            Button(action: { viewModel.logout() }) {
                                                HStack {
                                                    Image(systemName: "rectangle.portrait.and.arrow.forward.fill")
                                                    Text("Logout")
                                                }
                                                .fontWeight(.bold)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.red.opacity(0.8))
                                                .foregroundColor(.white)
                                                .clipShape(Capsule())
                                                .shadow(radius: 5)
                                            }
                                            .padding(.horizontal, 40)
                                            .padding(.bottom, 40)
                                        }
                                    }
                                }
                                .navigationBarHidden(true)
                            }
                        }
                    }
                    
                    

#Preview {
    ProfileView()
}
