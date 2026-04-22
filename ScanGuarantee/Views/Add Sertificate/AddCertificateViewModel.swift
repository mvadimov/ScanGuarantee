//
//  AddCertificateViewModel.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 16.04.26.
//

import SwiftUI
import Combine

final class AddCertificateViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var isProcessing = false
    @Published var parsedData: ParsedCertificateData?
    @Published var errorMessage: String?
    
    private let ocrService = OCRService()
    private let parser = CertificateParser()
    
    @MainActor
    func processImage(_ image: UIImage) async {
        isProcessing = true
        errorMessage = nil
        
        do {
            let result = try await ocrService.recognizeText(from: image)
            let parsed = parser.parse(result: result)
            self.selectedImage = image
            self.parsedData = parsed
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
}
