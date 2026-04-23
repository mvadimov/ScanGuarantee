//
//  Enum+HomeFilters.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 23.04.26.
//

import Foundation

enum HomeFilter: String, CaseIterable {
    case all = "Все"
    case active = "Активные"
    case expiring = "Истекают"
    case expired = "Истекли"
    
    static var first: Self {
        .all
    }
    
    static var last: Self {
        .expired
    }
}
