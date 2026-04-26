//
//  CertificateRepresentableProtocol.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 25.04.26.
//

import Foundation

protocol CertificateRepresentableProtocol {
    var productName: String { get }
    var validTo: Date { get }
}
