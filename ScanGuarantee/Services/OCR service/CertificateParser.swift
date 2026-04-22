import Foundation

final class CertificateParser {
    
    func parse(result: OCRScanResult) -> ParsedCertificateData {
        let text = result.rawText
        let lines = result.lines.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        let buyDate = extractBuyDate(from: text)
        let directValidTo = extractValidToDate(from: text)
        let warrantyMonths = extractWarrantyMonths(from: text)
        
        let computedValidTo: Date? = {
            if let directValidTo {
                return directValidTo
            }
            if let buyDate, let warrantyMonths {
                return Calendar.current.date(byAdding: .month, value: warrantyMonths, to: buyDate)
            }
            return nil
        }()
        
        return ParsedCertificateData(
            productName: extractProductName(from: lines),
            serialNumber: extractSerialNumber(from: text),
            buyDate: buyDate,
            validTo: computedValidTo,
            sellerName: extractSellerName(from: lines),
            sellerEmail: extractEmail(from: text),
            sellerPhone: extractPhone(from: text),
            rawText: text
        )
    }
}