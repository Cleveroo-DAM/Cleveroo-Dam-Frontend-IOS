//
//  ChildQRCodeLoginView.swift
//  Cleveroo
//
//  Child login via QR code scanning
//

import SwiftUI

struct ChildQRCodeLoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showScanner = false
    @State private var scannedToken: String?
    @State private var isAuthenticating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            BubbleBackground().ignoresSafeArea()
            
            if showScanner {
                // QR Scanner
                ZStack {
                    QRScannerView { code in
                        print("📷 QR Code scanned: \(code)")
                        scannedToken = code
                        showScanner = false
                    }
                    .ignoresSafeArea()
                    
                    // Scanning frame overlay
                    VStack {
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.yellow, lineWidth: 4)
                            .frame(width: 280, height: 280)
                            .overlay(
                                VStack(spacing: 20) {
                                    Image(systemName: "qrcode.viewfinder")
                                        .font(.system(size: 60))
                                        .foregroundColor(.yellow)
                                    
                                    Text("Scan QR Code")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(
                                            Capsule()
                                                .fill(Color.black.opacity(0.6))
                                        )
                                }
                            )
                        
                        Spacer()
                        
                        Button(action: {
                            showScanner = false
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                Text("Cancel")
                            }
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.8))
                            )
                            .shadow(color: Color.red.opacity(0.5), radius: 10)
                        }
                        .padding(.bottom, 50)
                    }
                }
            } else {
                // Main content
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer()
                            .frame(height: 50)
                        
                        // Logo
                        Image("Cleveroo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 130, height: 130)
                            .shadow(color: .white.opacity(0.8), radius: 20)
                            .scaleEffect(showContent ? 1.0 : 0.8)
                            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showContent)
                        
                        // Title
                        VStack(spacing: 10) {
                            Text("🎮 QR Login")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Scan the QR code from your parent's device")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        
                        // Content card
                        VStack(spacing: 25) {
                            // Scanned token display
                            if let token = scannedToken {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("QR Code Scanned")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text(token.prefix(20) + "...")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.green, lineWidth: 1)
                                        )
                                )
                            }
                            
                            // Scan button
                            Button(action: {
                                showScanner = true
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "qrcode.viewfinder")
                                        .font(.system(size: 24))
                                    Text(scannedToken == nil ? "Scan QR Code" : "Scan Again")
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                                .shadow(color: Color.blue.opacity(0.5), radius: 10)
                            }
                            .disabled(isAuthenticating)
                            
                            // Login button (only shown when token is scanned)
                            if scannedToken != nil {
                                Button(action: authenticateWithQR) {
                                    HStack(spacing: 10) {
                                        if isAuthenticating {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        } else {
                                            Image(systemName: "lock.open.fill")
                                            Text("Login")
                                                .fontWeight(.bold)
                                        }
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [Color.green, Color.cyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(Capsule())
                                    .shadow(color: Color.green.opacity(0.5), radius: 10)
                                }
                                .disabled(isAuthenticating)
                            }
                            
                            // Error message
                            if !errorMessage.isEmpty {
                                HStack(spacing: 10) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text(errorMessage)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.orange.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.orange, lineWidth: 1)
                                        )
                                )
                            }
                            
                            // Info card
                            VStack(alignment: .leading, spacing: 15) {
                                InfoRow(icon: "1.circle.fill", text: "Ask your parent to generate QR code", color: .cyan)
                                InfoRow(icon: "2.circle.fill", text: "Scan the QR code with camera", color: .blue)
                                InfoRow(icon: "3.circle.fill", text: "Tap Login to access your account", color: .purple)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white.opacity(0.1))
                            )
                        }
                        .padding(.horizontal, 30)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        
                        // Back button
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back to Login Options")
                            }
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.yellow)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .opacity(showContent ? 1 : 0)
                        
                        Spacer()
                    }
                }
            }
        }
        .navigationBarHidden(showScanner)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                showContent = true
            }
        }
        .alert("Authentication Error", isPresented: $showError) {
            Button("OK", role: .cancel) {
                errorMessage = ""
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Authentication Action
    private func authenticateWithQR() {
        guard let token = scannedToken, !token.isEmpty else {
            errorMessage = "No QR code scanned"
            showError = true
            return
        }
        
        isAuthenticating = true
        errorMessage = ""
        
        viewModel.exchangeQrToken(token) { success, error in
            isAuthenticating = false
            
            if success {
                print("✅ QR authentication successful")
                // Navigation is handled by RootView observing viewModel.isLoggedIn
            } else {
                errorMessage = error ?? "Authentication failed"
                showError = true
                scannedToken = nil // Reset token on error
                print("❌ QR authentication failed: \(errorMessage)")
            }
        }
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

#Preview {
    ChildQRCodeLoginView(viewModel: AuthViewModel())
}
