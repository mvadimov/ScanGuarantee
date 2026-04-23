//
//  ScanCertificateViewModel.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 21.04.26.
//

import SwiftUI
import PhotosUI
import Combine

@MainActor
final class ScanCertificateViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var selectedImageData: Data?
    @Published var parsedData: ParsedCertificateModel?
    @Published var errorMessage: String?
    
    private let ocrService = OCRService()
    private let parser = CertificateParser()
    
    func processImageData(_ data: Data) async {
        guard let image = UIImage(data: data) else {
            errorMessage = "Не удалось открыть изображение."
            return
        }
        
        isProcessing = true
        errorMessage = nil
        
        do {
            let ocrResult = try await ocrService.recognizeText(from: image)
            print("===== OCR RAW TEXT =====")
            print(ocrResult.rawText)
            print("========================")
            let parsed = parser.parse(ocrResult)
            
            selectedImageData = data
            parsedData = parsed
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
}
