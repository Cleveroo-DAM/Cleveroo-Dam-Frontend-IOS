//
//  ProfileView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 5/11/2025.
//

import SwiftUI
import WebKit

struct ProfileView: View {
    @ObservedObject var viewModel: AuthViewModel
    var onLogout: () -> Void

    @State private var showEditProfile = false
    @State private var showChangePassword = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {

                    // Avatar Image using AvatarImageView
                    AvatarImageView(avatarUrl: viewModel.avatarURL, size: 120)
                        .padding(.top, 40)

                    // Profile Info
                    VStack(spacing: 12) {
                        if viewModel.isParent {
                            Text("Parent Email: \(viewModel.parentEmail)").foregroundColor(.white)
                            Text("Parent Phone: \(viewModel.parentPhone)").foregroundColor(.white.opacity(0.9))
                            Text("Child Name: \(viewModel.childUsername)").foregroundColor(.white.opacity(0.9))
                        } else {
                            Text("Child Username: \(viewModel.childUsername)").font(.title2).fontWeight(.bold).foregroundColor(.white)
                            Text("Age: \(viewModel.age)").foregroundColor(.white.opacity(0.9))
                        }
                        Text("Role: \(viewModel.isParent ? "Parent" : "Child")").foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple.opacity(0.25))
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.5), lineWidth: 1.5))
                    .padding(.horizontal, 30)

                    // Profile Actions
                    VStack(spacing: 15) {
                        Button(action: { showEditProfile = true }) {
                            HStack {
                                Image(systemName: "pencil.circle.fill")
                                Text("Edit Profile")
                            }
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [Color.cyan.opacity(0.7), Color.blue.opacity(0.6)],
                                                       startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 5)
                        }
                        .sheet(isPresented: $showEditProfile) {
                            EditProfileView(viewModel: viewModel)
                        }

                        if viewModel.isParent {
                            Button(action: { showChangePassword = true }) {
                                HStack {
                                    Image(systemName: "key.fill")
                                    Text("Change Password")
                                }
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(colors: [Color.purple, Color.pink.opacity(0.8)],
                                                           startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                                .shadow(radius: 5)
                            }
                            .sheet(isPresented: $showChangePassword) {
                                ResetPasswordView(email: viewModel.parentEmail)
                            }
                        }

                        Button(action: { onLogout() }) {
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
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 40)
                }
            }
            .background(BubbleBackground().ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        onLogout()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                        }
                        .foregroundColor(.white)
                    }
                }
            }
            .onAppear {
                print("🔍 ProfileView onAppear - fetching profile...")
                print("   Current avatarURL: \(viewModel.avatarURL ?? "nil")")
                viewModel.fetchProfile()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    print("   After fetchProfile - avatarURL: \(viewModel.avatarURL ?? "nil")")
                }
            }
        }
    }
}

#Preview {
    ProfileView(viewModel: AuthViewModel(), onLogout: {})
}
