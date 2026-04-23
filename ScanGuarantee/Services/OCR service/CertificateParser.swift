//
//  CertificateParser.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 16.04.26.
//

import Foundation

final class CertificateParser {
    func parse(_ result: OCRResult) -> ParsedCertificateModel {
        let lines = normalizedLines(result.lines)
        let joinedText = normalizedText(lines.joined(separator: "\n"))
        
        print("===== OCR NORMALIZED TEXT =====")
        print(joinedText)
        print("===============================")
        
        let productName = extractProductName(from: lines)
        let serialNumber = extractSerialNumber(from: lines)
        let buyDate = extractBuyDate(from: lines)
        let directValidTo = extractValidToDate(from: lines)
        let warrantyMonths = extractWarrantyMonths(from: joinedText)
        
        let validTo: Date? = {
            if let directValidTo {
                return directValidTo
            }
            if let buyDate, let warrantyMonths {
                return Calendar.current.date(byAdding: .month, value: warrantyMonths, to: buyDate)
            }
            return nil
        }()
        
        print("===== PARSED DATA =====")
        print("productName:", productName ?? "nil")
        print("serialNumber:", serialNumber ?? "nil")
        print("buyDate:", buyDate?.description ?? "nil")
        print("validTo:", validTo?.description ?? "nil")
        print("warrantyMonths:", warrantyMonths.map(String.init) ?? "nil")
        print("=======================")
        
        return ParsedCertificateModel(
            productName: productName,
            serialNumber: serialNumber,
            buyDate: buyDate,
            validTo: validTo,
            sellerName: nil,
            rawText: joinedText
        )
    }
}

private extension CertificateParser {
    func normalizedText(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "”", with: "")
            .replacingOccurrences(of: "“", with: "")
            .replacingOccurrences(of: "‘", with: "")
            .replacingOccurrences(of: "’", with: "")
            .replacingOccurrences(of: "«", with: "")
            .replacingOccurrences(of: "»", with: "")
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func normalizedLines(_ lines: [String]) -> [String] {
        lines
            .map { sanitizeLine($0) }
            .filter { !$0.isEmpty }
    }
    
    func sanitizeLine(_ line: String) -> String {
        line
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "”", with: "")
            .replacingOccurrences(of: "“", with: "")
            .replacingOccurrences(of: "‘", with: "")
            .replacingOccurrences(of: "’", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func cleanupValue(_ text: String) -> String {
        text
            .replacingOccurrences(of: "•", with: "")
            .replacingOccurrences(of: "«", with: "")
            .replacingOccurrences(of: "»", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private extension CertificateParser {
    func extractProductName(from lines: [String]) -> String? {
        if let inlineName = extractInlineProductName(from: lines) {
            return inlineName
        }
        
        if let modelBasedName = extractProductNameAfterModelLabel(from: lines) {
            return modelBasedName
        }
        
        if let articleBasedName = extractProductNameAfterArticleLabel(from: lines) {
            return articleBasedName
        }
        
        for line in lines {
            let candidate = cleanupValue(line)
            if looksLikeProductCandidate(candidate) {
                return candidate
            }
        }
        
        return nil
    }
    
    func extractInlineProductName(from lines: [String]) -> String? {
        let prefixes = [
            "наименование товара",
            "товар",
            "product name"
        ]
        
        for line in lines {
            let cleaned = cleanupValue(line)
            
            for prefix in prefixes {
                guard let range = cleaned.range(of: prefix, options: .caseInsensitive) else { continue }
                
                let tail = cleaned[range.upperBound...]
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: CharacterSet(charactersIn: ":"))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                let candidate = String(tail)
                if looksLikeProductCandidate(candidate) {
                    return candidate
                }
            }
        }
        
        return nil
    }
    
    func extractProductNameAfterModelLabel(from lines: [String]) -> String? {
        let modelKeywords = [
            "модель/артикул",
            "модель",
            "артикул"
        ]
        
        for (index, line) in lines.enumerated() {
            let lower = line.lowercased()
            guard modelKeywords.contains(where: { lower.contains($0) }) else { continue }
            
            let start = index + 1
            let end = min(index + 8, lines.count - 1)
            guard start <= end else { continue }
            
            for nextIndex in start...end {
                let candidate = cleanupValue(lines[nextIndex])
                
                guard !candidate.isEmpty else { continue }
                guard !looksLikeLabel(candidate) else { continue }
                
                if looksLikeProductCandidate(candidate) {
                    return candidate
                }
            }
        }
        
        return nil
    }
    
    func extractProductNameAfterArticleLabel(from lines: [String]) -> String? {
        let keywords = [
            "артикул, вид товара",
            "вид товара",
            "наименование товара"
        ]
        
        for (index, line) in lines.enumerated() {
            let lower = line.lowercased()
            guard keywords.contains(where: { lower.contains($0) }) else { continue }
            
            let start = index + 1
            let end = min(index + 6, lines.count - 1)
            guard start <= end else { continue }
            
            for nextIndex in start...end {
                let candidate = cleanupValue(lines[nextIndex])
                
                guard !candidate.isEmpty else { continue }
                guard !looksLikeLabel(candidate) else { continue }
                
                if looksLikeProductCandidate(candidate) {
                    return candidate
                }
            }
        }
        
        return nil
    }
    
    func looksLikeProductCandidate(_ text: String) -> Bool {
        let candidate = cleanupValue(text)
        let lower = candidate.lowercased()
        
        guard candidate.count >= 3 else { return false }
        guard wordCount(candidate) <= 8 else { return false }
        guard containsLetters(candidate) else { return false }
        
        guard !containsDate(candidate) else { return false }
        guard !containsPhone(candidate) else { return false }
        guard !containsEmail(candidate) else { return false }
        guard !containsURL(candidate) else { return false }
        guard !looksLikeSerialCandidate(candidate) else { return false }
        
        let blacklist = [
            "premium",
            "sagaminskservice",
            "гарантийный талон",
            "гарантийная карта",
            "гарантийный сертификат",
            "гарантия",
            "дата покупки",
            "дата продажи",
            "сведения о продавце",
            "сервисное обслуживание",
            "сервисное облуживание",
            "сервисное обслуживание и ремонт",
            "режим работы",
            "модель",
            "модель:",
            "модель/артикул",
            "серийный номер",
            "imei/sn",
            "imensn",
            "imei",
            "sn",
            "число/месяц/год",
            "в месяцах",
            "цена",
            "цена:",
            "byn",
            "артикул, вид товара",
            "вид товара",
            "телефон магазина",
            "без обеда и выходных",
            "гарантийное обслуживание"
        ]
        
        guard blacklist.allSatisfy({ !lower.contains($0) }) else { return false }
        
        return true
    }
}

private extension CertificateParser {
    func extractBuyDate(from lines: [String]) -> Date? {
        let keywords = [
            "дата покупки",
            "дата продажи",
            "purchase date",
            "date of purchase"
        ]
        
        for (index, line) in lines.enumerated() {
            let lower = line.lowercased()
            guard keywords.contains(where: { lower.contains($0) }) else { continue }
            
            let end = min(index + 6, lines.count - 1)
            guard index <= end else { continue }
            
            let windowLines = Array(lines[index...end])
            let joined = windowLines.joined(separator: " ")
            
            if let date = extractFirstDate(from: joined) {
                return date
            }
            
            if let splitDate = extractSplitDate(from: windowLines) {
                return splitDate
            }
        }
        
        if let fallback = extractSplitDate(from: lines) {
            return fallback
        }
        
        return extractFirstDate(from: lines.joined(separator: " "))
    }
    
    func extractValidToDate(from lines: [String]) -> Date? {
        let keywords = [
            "гарантия до",
            "действительна до",
            "valid until",
            "warranty until",
            "годен до"
        ]
        
        for (index, line) in lines.enumerated() {
            let lower = line.lowercased()
            guard keywords.contains(where: { lower.contains($0) }) else { continue }
            
            let end = min(index + 6, lines.count - 1)
            guard index <= end else { continue }
            
            let windowLines = Array(lines[index...end])
            let joined = windowLines.joined(separator: " ")
            
            if let date = extractFirstDate(from: joined) {
                return date
            }
            
            if let splitDate = extractSplitDate(from: windowLines) {
                return splitDate
            }
        }
        
        return nil
    }
    
    func extractWarrantyMonths(from text: String) -> Int? {
        let lower = text.lowercased()
        
        let monthPatterns = [
            #"(?:гарантийное обслуживание|гарантийный срок|гарантия|срок гарантии)[^\d]{0,30}(\d{1,2})\s*(?:мес|месяц|месяцев|months?)"#,
            #"(\d{1,2})\s*(?:мес|месяц|месяцев|months?)"#
        ]
        
        for pattern in monthPatterns {
            if let value = firstCapturedInt(pattern: pattern, in: lower) {
                return value
            }
        }
        
        let yearPatterns = [
            #"(?:гарантийный срок|гарантия|срок гарантии)[^\d]{0,30}(\d{1,2})\s*(?:год|года|лет|years?)"#,
            #"(\d{1,2})\s*(?:год|года|лет|years?)"#
        ]
        
        for pattern in yearPatterns {
            if let value = firstCapturedInt(pattern: pattern, in: lower) {
                return value * 12
            }
        }
        
        return nil
    }
    
    func extractFirstDate(from text: String) -> Date? {
        let candidates = regexMatches(
            pattern: #"\b\d{1,2}[./]\s?\d{1,2}[./]\s?\d{4}\b|\b\d{4}-\d{2}-\d{2}\b"#,
            in: text
        )
        
        let formatters = makeDateFormatters()
        
        for raw in candidates {
            let cleaned = raw.replacingOccurrences(of: " ", with: "")
            for formatter in formatters {
                if let date = formatter.date(from: cleaned) {
                    return date
                }
            }
        }
        
        return nil
    }
    
    func extractSplitDate(from lines: [String]) -> Date? {
        let cleaned = lines.map {
            cleanupValue($0)
                .replacingOccurrences(of: ".", with: "")
                .replacingOccurrences(of: "/", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        guard cleaned.count >= 3 else { return nil }
        
        for i in 0..<(cleaned.count - 2) {
            let d = cleaned[i]
            let m = cleaned[i + 1]
            let y = cleaned[i + 2]
            
            guard d.range(of: #"^\d{1,2}$"#, options: .regularExpression) != nil else { continue }
            guard m.range(of: #"^\d{1,2}$"#, options: .regularExpression) != nil else { continue }
            guard y.range(of: #"^\d{4}$"#, options: .regularExpression) != nil else { continue }
            
            let combined = "\(d).\(m).\(y)"
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "dd.MM.yyyy"
            
            if let date = formatter.date(from: combined) {
                return date
            }
        }
        
        return nil
    }
    
    func makeDateFormatters() -> [DateFormatter] {
        let formats = [
            "dd.MM.yyyy",
            "dd/MM/yyyy",
            "yyyy-MM-dd"
        ]
        
        return formats.map { format in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = format
            return formatter
        }
    }
}

private extension CertificateParser {
    func extractSerialNumber(from lines: [String]) -> String? {
        let keywords = [
            "imei/sn",
            "imensn",
            "imei",
            "серийный номер",
            "serial number",
            "s/n",
            "sn"
        ]
        
        for (index, line) in lines.enumerated() {
            let lower = line.lowercased()
            guard keywords.contains(where: { lower.contains($0) }) else { continue }
            
            let end = min(index + 8, lines.count - 1)
            let start = index + 1
            guard start <= end else { continue }
            
            for nextIndex in start...end {
                let candidate = cleanupValue(lines[nextIndex])
                if looksLikeSerialCandidate(candidate) {
                    return candidate
                }
            }
        }
        
        for line in lines {
            let candidate = cleanupValue(line)
            if looksLikeSerialCandidate(candidate) {
                return candidate
            }
        }
        
        return nil
    }
    
    func looksLikeSerialCandidate(_ text: String) -> Bool {
        let candidate = cleanupValue(text)
        let compact = candidate.replacingOccurrences(of: " ", with: "")
        let lower = candidate.lowercased()
        
        guard candidate.count >= 6 else { return false }
        guard !containsDate(candidate) else { return false }
        guard !containsPhone(candidate) else { return false }
        guard !containsEmail(candidate) else { return false }
        guard !containsURL(candidate) else { return false }
        
        let blacklist = [
            "гарантия",
            "дата",
            "продавец",
            "модель",
            "серийный номер",
            "imei/sn",
            "imensn",
            "гарантийный талон",
            "гарантийная карта",
            "гарантийный сертификат",
            "цена",
            "byn",
            "apple pencil"
        ]
        
        guard blacklist.allSatisfy({ !lower.contains($0) }) else { return false }
        
        let alnumCount = compact.filter { $0.isLetter || $0.isNumber }.count
        let digitCount = compact.filter { $0.isNumber }.count
        let letterCount = compact.filter { $0.isLetter }.count
        
        if digitCount >= 8 && alnumCount == digitCount {
            return true
        }
        
        return alnumCount >= 6 && digitCount >= 2 && letterCount >= 1
    }
}

private extension CertificateParser {
    func regexMatches(pattern: String, in text: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        
        return regex.matches(in: text, range: range).compactMap {
            Range($0.range, in: text).map { String(text[$0]) }
        }
    }
    
    func firstCapturedInt(pattern: String, in text: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        
        guard
            let match = regex.firstMatch(in: text, range: range),
            match.numberOfRanges > 1,
            let captureRange = Range(match.range(at: 1), in: text)
        else {
            return nil
        }
        
        return Int(String(text[captureRange]))
    }
}

private extension CertificateParser {
    func looksLikeLabel(_ text: String) -> Bool {
        let lower = text.lowercased()
        
        let exactOrPrefixLabels = [
            "дата",
            "гарантия",
            "продавец",
            "сведения",
            "модель",
            "серийный",
            "номер",
            "imei",
            "imensn",
            "sn",
            "телефон",
            "срок",
            "товар",
            "в месяцах",
            "число/месяц/год",
            "гарантийное обслуживание",
            "артикул, вид товара",
            "вид товара",
            "цена"
        ]
        
        return exactOrPrefixLabels.contains(where: {
            lower == $0 || lower.contains($0 + ":")
        })
    }
    
    func containsDate(_ text: String) -> Bool {
        text.range(
            of: #"\b\d{1,2}[./]\s?\d{1,2}[./]\s?\d{4}\b|\b\d{4}-\d{2}-\d{2}\b"#,
            options: .regularExpression
        ) != nil
    }
    
    func containsPhone(_ text: String) -> Bool {
        text.range(
            of: #"(?:\+?\d[\d\-\(\) ]{8,}\d)"#,
            options: .regularExpression
        ) != nil
    }
    
    func containsEmail(_ text: String) -> Bool {
        text.range(
            of: #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#,
            options: .regularExpression
        ) != nil
    }
    
    func containsURL(_ text: String) -> Bool {
        let lower = text.lowercased()
        return lower.contains(".by") || lower.contains(".ru") || lower.contains(".com") || lower.contains("www.")
    }
    
    func containsLetters(_ text: String) -> Bool {
        text.range(of: #"[A-Za-zА-Яа-яЁё]"#, options: .regularExpression) != nil
    }
    
    func wordCount(_ text: String) -> Int {
        text.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count
    }
}
