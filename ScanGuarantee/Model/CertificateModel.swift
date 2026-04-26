//
//  CertificateModel.swift
//  ScanGarant
//
//  Created by Mark Vadimov on 14.04.26.
//

import Foundation
import SwiftData

@Model
final class CertificateModel: Identifiable {
    var id: UUID = UUID()
    
    var productName: String
    var serialNumber: String?
    
    var buyDate: Date?
    var validTo: Date
    
    var sellerName: String?
    var sellerEmail: String?
    var sellerPhone: String?
    
    var imageData: Data?
    var rawText: String?
    
    var notifyEnabled: Bool = true
    var notifyDaysBefore: Int = 7
    
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    init(
        productName: String,
        serialNumber: String? = nil,
        buyDate: Date? = nil,
        validTo: Date,
        sellerName: String? = nil,
        sellerEmail: String? = nil,
        sellerPhone: String? = nil,
        imageData: Data? = nil,
        rawText: String? = nil
    ) {
        self.productName = productName
        self.serialNumber = serialNumber
        self.buyDate = buyDate
        self.validTo = validTo
        self.sellerName = sellerName
        self.sellerEmail = sellerEmail
        self.sellerPhone = sellerPhone
        self.imageData = imageData
        self.rawText = rawText
    }
}

extension CertificateModel: CertificateRepresentableProtocol {}
