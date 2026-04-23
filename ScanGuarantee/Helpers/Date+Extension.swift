//
//  Date+Extension.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 21.04.26.
//

import Foundation

extension Date {
    private static let ruFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    func ruDate() -> String {
        Self.ruFormatter.string(from: self)
    }
}

