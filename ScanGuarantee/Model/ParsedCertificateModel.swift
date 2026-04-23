//
//  ParsedCertificateModel.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 16.04.26.
//

import Foundation

struct ParsedCertificateModel {
    var productName: String?
    var serialNumber: String?
    var buyDate: Date?
    var validTo: Date?
    var sellerName: String?
    var rawText: String
}
