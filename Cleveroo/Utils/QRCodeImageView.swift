//
//  QRCodeImageView.swift
//  Cleveroo
//
//  Vue pour afficher un code QR généré en Base64

import SwiftUI

struct QRCodeImageView: View {
    let qrCodeBase64: String?
    let size: CGFloat = 250
    
    var body: some View {
        if let qrCodeBase64 = qrCodeBase64,
           let imageData = Data(base64Encoded: qrCodeBase64),
           let uiImage = UIImage(data: imageData) {
            VStack(spacing: 15) {
                Image(uiImage: uiImage)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.2), radius: 10)
                
                Text("Share this QR code with your child")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        } else {
            VStack(spacing: 10) {
                Image(systemName: "qrcode")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.5))
                
                Text("QR Code not available")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(width: size, height: size)
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
        }
    }
}

#Preview {
    QRCodeImageView(qrCodeBase64: nil)
        .background(Color.purple.ignoresSafeArea())
}
