//
//  AddCertificateViewModel.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 16.04.26.
//

import SwiftUI
import SwiftData
import PhotosUI
import Combine

@MainActor
final class AddCertificateViewModel: ObservableObject {
    @Published var productName: String
    @Published var validTo: Date
    @Published var selectedImageData: Data?
    
    @Published var isValidColorOfName: Color = .mainYellow
    @Published var showNotificationAlert: Bool = false
    
    init(
        productName: String = "",
        validTo: Date = Date(),
        selectedImageData: Data? = nil
    ) {
        self.productName = productName
        self.validTo = validTo
        self.selectedImageData = selectedImageData
    }
    
    var isFormValid: Bool {
        !productName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func resetValidationColorIfNeeded() {
        if isValidColorOfName != .mainYellow {
            isValidColorOfName = .mainYellow
        }
    }
    
    func markInvalidName() {
        isValidColorOfName = .red
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isValidColorOfName = .mainYellow
        }
    }
    
    func handleSelectedPhotoItem(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        
        if let data = try? await item.loadTransferable(type: Data.self) {
            if let uiImage = UIImage(data: data),
               let compressedData = uiImage.jpegData(compressionQuality: 0.75) {
                selectedImageData = compressedData
            } else {
                selectedImageData = data
            }
        }
    }
    
    func removeSelectedImage() {
        selectedImageData = nil
    }
    
    func save(context: ModelContext) async -> Bool {
        let trimmedName = productName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return false }
        
        let newItem = CertificateModel(
            productName: trimmedName,
            validTo: validTo,
            imageData: selectedImageData
        )
        
        context.insert(newItem)
        
        let isAuthorized = await NotificationService.shared.isAuthorized()
        
        if isAuthorized {
            await NotificationService.shared.scheduleNotification(for: newItem)
            return true
        } else {
            newItem.notifyEnabled = false
            showNotificationAlert = true
            return false
        }
    }
}
