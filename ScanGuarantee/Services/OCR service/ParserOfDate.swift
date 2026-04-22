//
//  Extension + Parser.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 16.04.26.
//

import Foundation

extension CertificateParser {
    
    func extractAllDates(from text: String) -> [Date] {
        let patterns = [
            #"\b\d{2}\.\d{2}\.\d{4}\b"#,
            #"\b\d{2}/\d{2}/\d{4}\b"#,
            #"\b\d{4}-\d{2}-\d{2}\b"#
        ]
        
        let formatters: [(String, DateFormatter)] = {
            let f1 = DateFormatter()
            f1.locale = Locale(identifier: "ru_RU")
            f1.dateFormat = "dd.MM.yyyy"
            
            let f2 = DateFormatter()
            f2.locale = Locale(identifier: "ru_RU")
            f2.dateFormat = "dd/MM/yyyy"
            
            let f3 = DateFormatter()
            f3.locale = Locale(identifier: "en_US_POSIX")
            f3.dateFormat = "yyyy-MM-dd"
            
            return [
                (patterns[0], f1),
                (patterns[1], f2),
                (patterns[2], f3)
            ]
        }()
        
        var dates: [Date] = []
        
        for (pattern, formatter) in formatters {
            let matches = regexMatches(pattern: pattern, in: text)
            for match in matches {
                if let date = formatter.date(from: match) {
                    dates.append(date)
                }
            }
        }
        
        return dates.sorted()
    }
    
    func extractBuyDate(from text: String) -> Date? {
        let lower = text.lowercased()
        
        let keywords = [
            "дата покупки",
            "дата продажи",
            "продан",
            "purchase date",
            "date of purchase"
        ]
        
        for keyword in keywords {
            if let nearby = extractDateNearKeyword(keyword, in: lower) {
                return nearby
            }
        }
        
        return extractAllDates(from: text).first
    }
    
    func extractValidToDate(from text: String) -> Date? {
        let lower = text.lowercased()
        
        let keywords = [
            "гарантия до",
            "действительна до",
            "valid until",
            "warranty until",
            "годен до"
        ]
        
        for keyword in keywords {
            if let nearby = extractDateNearKeyword(keyword, in: lower) {
                return nearby
            }
        }
        
        return nil
    }
    
    private func extractDateNearKeyword(_ keyword: String, in text: String) -> Date? {
        guard let range = text.range(of: keyword) else { return nil }
        
        let tail = String(text[range.lowerBound...])
        let dates = extractAllDates(from: tail)
        return dates.first
    }
}
