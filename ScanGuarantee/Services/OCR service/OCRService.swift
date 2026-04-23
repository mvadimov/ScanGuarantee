//
//  OCRService.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 16.04.26.
//

import UIKit
import Vision

final class OCRService {
    func recognizeText(from image: UIImage) async throws -> OCRResult {
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
                
                let lines = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                let rawText = lines.joined(separator: "\n")
                continuation.resume(returning: OCRResult(rawText: rawText, lines: lines))
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
