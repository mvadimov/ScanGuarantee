import Foundation
import UIKit
import PhotosUI

@MainActor
final class ScanCertificateViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var selectedImageData: Data?
    @Published var parsedData: ParsedCertificateData?
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
            let parsed = parser.parse(ocrResult)
            
            selectedImageData = data
            parsedData = parsed
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
}