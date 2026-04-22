import Foundation
import UIKit
import Vision

final class OCRService {
    
    func recognizeText(from image: UIImage) async throws -> OCRScanResult {
        guard let cgImage = image.cgImage else {
            throw OCRServiceError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                
                let strings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                let rawText = strings.joined(separator: "\n")
                continuation.resume(returning: OCRScanResult(rawText: rawText, lines: strings))
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["ru-RU", "en-US"]
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

enum OCRServiceError: Error {
    case invalidImage
}

struct OCRScanResult {
    let rawText: String
    let lines: [String]
}