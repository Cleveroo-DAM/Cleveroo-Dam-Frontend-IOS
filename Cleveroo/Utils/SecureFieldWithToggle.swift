//
//  SecureFieldWithToggle.swift
//  Cleveroo
//
//  Created on 13/11/2025
//

import SwiftUI

struct SecureFieldWithToggle: View {
    let placeholder: String
    @Binding var text: String
    @State private var isSecure: Bool = true
    
    var body: some View {
        HStack(spacing: 12) {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
            
            Button(action: {
                isSecure.toggle()
            }) {
                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.system(size: 18))
            }
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(15)
        .overlay(RoundedRectangle(cornerRadius: 15)
            .stroke(Color.white.opacity(0.3), lineWidth: 1))
    }
}

#Preview {
    ZStack {
        BubbleBackground()
        SecureFieldWithToggle(placeholder: "🔑 Password", text: .constant(""))
            .padding()
    }
}
