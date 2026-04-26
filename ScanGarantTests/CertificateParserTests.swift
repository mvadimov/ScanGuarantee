//
//  CertificateParserTests.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 25.04.26.
//

import XCTest
@testable import ScanGuarantee

final class CertificateParserTests: XCTestCase {
    let parser = CertificateParser()
    func testParserExtractsPrintedWarrantyData() {
        let ocrResult = OCRResult(
            rawText: """
            Гарантийная карта
            Модель/Артикул:
            IMEI/SN:
            Дата продажи:
            Гарантийное обслуживание:
            Наушники Apple AirPods
            DLCXRBD7H8TT
            23/06/2021
            12 месяцев
            """,
            lines: [
                "Гарантийная карта",
                "Модель/Артикул:",
                "IMEI/SN:",
                "Дата продажи:",
                "Гарантийное обслуживание:",
                "Наушники Apple AirPods",
                "DLCXRBD7H8TT",
                "23/06/2021",
                "12 месяцев"
            ]
        )
        
        let result = parser.parse(ocrResult)
        
        XCTAssertEqual(result.productName, "Наушники Apple AirPods")
        XCTAssertEqual(result.serialNumber, "DLCXRBD7H8TT")
        XCTAssertNotNil(result.buyDate)
        XCTAssertNotNil(result.validTo)
    }
    
    func testParserExtractsSplitDate() {
        let ocrResult = OCRResult(
            rawText: """
            Дата продажи:
            11
            10
            2017
            Apple Pencil
            """,
            lines: [
                "Дата продажи:",
                "11",
                "10",
                "2017",
                "Apple Pencil"
            ]
        )
        
        let result = parser.parse(ocrResult)
        
        XCTAssertNotNil(result.buyDate)
    }
}
