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
    let onBack: (() -> Void)? // Callback pour retourner à la vue précédente
    
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
                        
                        // Content card - SIMPLIFIED FOR BETTER INTERACTION
                        VStack(spacing: 20) {
                            // Scanned token display
                            if scannedToken != nil {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("QR Code Successfully Scanned ✅")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                    Text("Ready to login")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
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
                            Button(action: { showScanner = true }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "qrcode.viewfinder")
                                        .font(.system(size: 20))
                                    Text(scannedToken == nil ? "Scan QR Code" : "Scan Again")
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing))
                                .clipShape(Capsule())
                                .shadow(color: Color.blue.opacity(0.5), radius: 8)
                            }
                            .disabled(isAuthenticating)
                            
                            // Login button - MUST BE CLICKABLE
                            if scannedToken != nil {
                                Button(action: { authenticateWithQR() }) {
                                    if isAuthenticating {
                                        HStack {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            Text("Authenticating...")
                                        }
                                    } else {
                                        HStack(spacing: 8) {
                                            Image(systemName: "lock.open.fill")
                                            Text("Login Now")
                                        }
                                    }
                                }
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(LinearGradient(colors: [Color.green, Color.cyan], startPoint: .leading, endPoint: .trailing))
                                .clipShape(Capsule())
                                .shadow(color: Color.green.opacity(0.5), radius: 8)
                                .disabled(isAuthenticating)
                            }
                            
                            // Error message
                            if !errorMessage.isEmpty {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.orange)
                                    Text(errorMessage)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange.opacity(0.2)))
                            }
                            
                            // Info card
                            VStack(alignment: .leading, spacing: 10) {
                                QRInfoRow(icon: "1.circle.fill", text: "Parent generates QR code", color: Color.cyan)
                                QRInfoRow(icon: "2.circle.fill", text: "Scan with your device", color: Color.blue)
                                QRInfoRow(icon: "3.circle.fill", text: "Tap Login to access", color: Color.purple)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.1)))
                        }
                        .padding(.horizontal, 20)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        
                        // Back button
                        Button(action: {
                            if let onBack = onBack {
                                onBack()
                            } else {
                                dismiss()
                            }
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
            print("❌ QR Authentication Error: No token scanned")
            return
        }
        
        isAuthenticating = true
        errorMessage = ""
        
        print("🔐 Starting QR authentication with token: \(token)")
        
        viewModel.exchangeQrToken(token) { success, error in
            DispatchQueue.main.async {
                self.isAuthenticating = false
                
                if success {
                    print("✅ QR authentication successful - Token exchanged successfully")
                    // Navigation is handled by RootView observing viewModel.isLoggedIn
                } else {
                    let errorMsg = error ?? "Authentication failed - Unknown error"
                    self.errorMessage = errorMsg
                    self.showError = true
                    self.scannedToken = nil // Reset token on error
                    print("❌ QR authentication failed: \(errorMsg)")
                }
            }
        }
    }
}

// MARK: - Info Row Component
struct QRInfoRow: View {
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
    ChildQRCodeLoginView(viewModel: AuthViewModel(), onBack: nil)
}
