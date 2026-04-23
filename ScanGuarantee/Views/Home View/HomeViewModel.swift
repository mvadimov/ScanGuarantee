//
//  HomeViewModel.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 15.04.26.
//

import SwiftUI
import PhotosUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedFilter: HomeFilter = .all
    @Published var selectedCertificate: CertificateModel?
    
    @Published var addRoute: AddCertificateRoute?
    @Published var ocrErrorText: String = ""
    @Published var showOCRError: Bool = false
    
    private let scanViewModel = ScanCertificateViewModel()
    
    var selectedFilterRaw: String {
        get { selectedFilter.rawValue }
        set { selectedFilter = HomeFilter(rawValue: newValue) ?? .all }
    }
    
    func filteredItems(_ items: [CertificateModel]) -> [CertificateModel] {
        let now = Date()
        
        return items.filter { item in
            let matchesSearch =
                searchText.isEmpty ||
                item.productName.localizedCaseInsensitiveContains(searchText)
            
            let matchesFilter: Bool
            
            switch selectedFilter {
            case .all:
                matchesFilter = true
            case .active:
                matchesFilter = item.validTo > now
            case .expiring:
                if let days7 = Calendar.current.date(byAdding: .day, value: 7, to: now) {
                    matchesFilter = item.validTo > now && item.validTo <= days7
                } else {
                    matchesFilter = false
                }
            case .expired:
                matchesFilter = item.validTo <= now
            }
            
            return matchesSearch && matchesFilter
        }
        .sorted { $0.validTo > $1.validTo }
    }
    
    func openManualAdd() {
        addRoute = .manual
    }
    
    func openCertificate(_ item: CertificateModel) {
        selectedCertificate = item
    }
    
    func closeCertificate() {
        selectedCertificate = nil
    }
    
    func handleCameraImage(_ image: UIImage?) async {
        guard let image else { return }
        
        guard let data = image.jpegData(compressionQuality: 0.75) else {
            ocrErrorText = "Не удалось обработать фото"
            showOCRError = true
            return
        }
        
        await handleImageData(data)
    }
    
    func handlePhotoPickerItem(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            ocrErrorText = "Не удалось загрузить изображение"
            showOCRError = true
            return
        }
        
        await handleImageData(data)
    }
    
    func handleImageData(_ data: Data) async {
        await scanViewModel.processImageData(data)
        
        if let error = scanViewModel.errorMessage {
            ocrErrorText = error
            showOCRError = true
            return
        }
        
        let parsed = scanViewModel.parsedData
        
        addRoute = .ocr(
            productName: parsed?.productName ?? "",
            validTo: parsed?.validTo ?? Date(),
            imageData: scanViewModel.selectedImageData
        )
    }
    
    func dismissAlert() {
        showOCRError = false
        ocrErrorText = ""
    }
}
