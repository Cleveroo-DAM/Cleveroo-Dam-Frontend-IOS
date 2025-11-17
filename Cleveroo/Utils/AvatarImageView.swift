//
//  AvatarImageView.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 16/11/2025
//

import SwiftUI

struct AvatarImageView: View {
    let avatarUrl: String?
    let size: CGFloat
    let fallbackImage: String = "Cleveroo"
    
    private var fullURL: URL? {
        guard let urlString = avatarUrl, !urlString.isEmpty else {
            print("🖼️ AvatarImageView: No URL provided")
            return nil
        }
        
        // Convertir les URLs SVG de DiceBear en PNG (AsyncImage ne supporte pas SVG)
        var processedURL = urlString
        if urlString.contains("dicebear.com") && urlString.contains("/svg") {
            processedURL = urlString.replacingOccurrences(of: "/svg?", with: "/png?")
            print("🖼️ AvatarImageView: Converting SVG to PNG: \(processedURL)")
        }
        
        // Si l'URL commence par http:// ou https://, l'utiliser directement
        if processedURL.hasPrefix("http://") || processedURL.hasPrefix("https://") {
            print("🖼️ AvatarImageView: Using full URL: \(processedURL)")
            return URL(string: processedURL)
        }
        
        // Sinon, construire l'URL complète avec le backend
        let baseURL = "http://localhost:3000"
        let fullURLString = processedURL.hasPrefix("/") ? "\(baseURL)\(processedURL)" : "\(baseURL)/\(processedURL)"
        print("🖼️ AvatarImageView: Building full URL: \(fullURLString)")
        return URL(string: fullURLString)
    }
    
    var body: some View {
        Group {
            if let url = fullURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Circle()
                                .fill(Color.purple.opacity(0.3))
                                .frame(width: size, height: size)
                            ProgressView()
                                .tint(.white)
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                            .onAppear {
                                print("✅ Avatar loaded successfully from: \(url.absoluteString)")
                            }
                    case .failure(let error):
                        // Fallback to local image if URL fails
                        ZStack {
                            Image(fallbackImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: size, height: size)
                                .clipShape(Circle())
                            
                            VStack {
                                Spacer()
                                Text("⚠️")
                                    .font(.caption2)
                            }
                        }
                        .onAppear {
                            print("❌ Failed to load avatar from: \(url.absoluteString)")
                            print("   Error: \(error.localizedDescription)")
                        }
                    @unknown default:
                        Image(fallbackImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    }
                }
            } else {
                // No URL provided, use fallback
                Image(fallbackImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .onAppear {
                        print("🖼️ Using fallback image (no valid URL)")
                    }
            }
        }
        .shadow(color: Color.white.opacity(0.8), radius: 10)
    }
}

#Preview {
    VStack(spacing: 20) {
        // With full URL
        AvatarImageView(
            avatarUrl: "https://api.dicebear.com/7.x/avataaars/png?seed=test",
            size: 120
        )
        
        // With relative URL
        AvatarImageView(
            avatarUrl: "/uploads/avatar.jpg",
            size: 120
        )
        
        // Without URL (fallback)
        AvatarImageView(
            avatarUrl: nil,
            size: 120
        )
    }
    .padding()
    .background(BubbleBackground())
}
