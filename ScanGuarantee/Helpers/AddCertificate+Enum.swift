//
//  AddCertificate+Enum.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 21.04.26.
//

import Foundation

enum AddCertificateRoute: Identifiable {
    case manual
    case ocr(productName: String, validTo: Date, imageData: Data?)
    
    var id: String {
        switch self {
        case .manual:
            return "manual"
        case .ocr(let productName, let validTo, _):
            return "ocr_\(productName)_\(validTo.timeIntervalSince1970)"
        }
    }
}
