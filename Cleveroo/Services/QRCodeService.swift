//
//  QRCodeService.swift
//  Cleveroo
//
//  Service pour générer et gérer les codes QR

import Foundation
import CoreImage
import UIKit

class QRCodeService {
    static let shared = QRCodeService()
    
    private init() {}
    
    private let baseURL = APIConfig.qrBaseURL
    
    // MARK: - Générer un token QR depuis le backend
    /// Génère un token QR permanent pour un enfant via le backend
    /// Le token est réutilisable et n'expire jamais
    func generateQRTokenForChild(
        childId: String,
        token: String,
        completion: @escaping (String?, String?, Error?) -> Void
    ) {
        let endpoint = "\(baseURL)/children/\(childId)/generate"
        let body: [String: Any] = [
            "returnQrImage": true
        ]
        
        guard let url = URL(string: endpoint) else {
            completion(nil, nil, NSError(domain: "Invalid URL", code: -1))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(nil, nil, error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error generating QR token: \(error.localizedDescription)")
                completion(nil, nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, nil, NSError(domain: "No data", code: -1))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let qrToken = json["token"] as? String
                    let qrDataUri = json["qrDataUri"] as? String
                    
                    print("✅ QR token generated successfully")
                    print("   Token: \(qrToken?.prefix(20) ?? "nil")...")
                    
                    completion(qrToken, qrDataUri, nil)
                }
            } catch {
                completion(nil, nil, error)
            }
        }.resume()
    }
    
    // MARK: - Générer une image QR à partir d'un token
    /// Génère une image QR à partir d'une chaîne (token) et la retourne en Base64
    func generateQRCode(from string: String, size: CGSize = CGSize(width: 300, height: 300)) -> String? {
        guard let data = string.data(using: .utf8) else { return nil }
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        
        guard let ciImage = filter?.outputImage else { return nil }
        
        // Redimensionner l'image
        let transform = CGAffineTransform(scaleX: size.width / ciImage.extent.size.width,
                                         y: size.height / ciImage.extent.size.height)
        let scaledImage = ciImage.transformed(by: transform)
        
        // Convertir en UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        let uiImage = UIImage(cgImage: cgImage)
        
        // Convertir en PNG et encoder en Base64
        guard let pngData = uiImage.pngData() else { return nil }
        return pngData.base64EncodedString()
    }
    
    /// Convertir un DataURI (image/png;base64,...) en UIImage
    func uiImageFromDataURI(_ dataURI: String) -> UIImage? {
        // Format: "data:image/png;base64,iVBORw0KGgo..."
        guard let base64String = dataURI.components(separatedBy: ",").last,
              let imageData = Data(base64Encoded: base64String),
              let image = UIImage(data: imageData) else {
            return nil
        }
        return image
    }
    
    /// Convertir un DataURI en Base64 string pour stockage
    func base64FromDataURI(_ dataURI: String) -> String? {
        guard let base64String = dataURI.components(separatedBy: ",").last else {
            return nil
        }
        return base64String
    }
}

