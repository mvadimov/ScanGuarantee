//
//  HomeViewModelTests.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 25.04.26.
//

import XCTest
@testable import ScanGuarantee

@MainActor
final class HomeViewModelTests: XCTestCase {
    let now = Date()
    let viewModel = HomeViewModel()
    func testFilteredItemsForAllFilters() {
        let active = MockCertificate(
            productName: "MacBook",
            validTo: Calendar.current.date(byAdding: .day, value: 30, to: now)!
        )
        
        let expiring = MockCertificate(
            productName: "AirPods",
            validTo: Calendar.current.date(byAdding: .day, value: 3, to: now)!
        )
        
        let expired = MockCertificate(
            productName: "iPhone",
            validTo: Calendar.current.date(byAdding: .day, value: -2, to: now)!
        )
        
        let items = [active, expiring, expired]
        
        viewModel.selectedFilter = .all
        XCTAssertEqual(viewModel.filteredItems(items).count, 3)
        
        viewModel.selectedFilter = .active
        XCTAssertEqual(viewModel.filteredItems(items).count, 2)
        
        viewModel.selectedFilter = .expiring
        let expiringResult = viewModel.filteredItems(items)
        XCTAssertEqual(expiringResult.count, 1)
        XCTAssertEqual(expiringResult.first?.productName, "AirPods")
        
        viewModel.selectedFilter = .expired
        let expiredResult = viewModel.filteredItems(items)
        XCTAssertEqual(expiredResult.count, 1)
        XCTAssertEqual(expiredResult.first?.productName, "iPhone")
    }
    
    func testSearchFiltersByProductName() {
        viewModel.searchText = "air"
        
        let items = [
            MockCertificate(productName: "MacBook Pro", validTo: Date()),
            MockCertificate(productName: "AirPods Pro", validTo: Date()),
            MockCertificate(productName: "iPhone", validTo: Date())
        ]
        
        let result = viewModel.filteredItems(items)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.productName, "AirPods Pro")
    }
    
    func testFilteredItemsAppliesSearchFilterAndSortingTogether() {
        let items = [
            MockCertificate(
                productName: "AirPods Old",
                validTo: Calendar.current.date(byAdding: .day, value: -2, to: now)!
            ),
            MockCertificate(
                productName: "AirPods Soon",
                validTo: Calendar.current.date(byAdding: .day, value: 3, to: now)!
            ),
            MockCertificate(
                productName: "AirPods Later",
                validTo: Calendar.current.date(byAdding: .day, value: 6, to: now)!
            ),
            MockCertificate(
                productName: "MacBook Soon",
                validTo: Calendar.current.date(byAdding: .day, value: 2, to: now)!
            )
        ]
        
        viewModel.searchText = "airpods"
        viewModel.selectedFilter = .expiring
        
        let result = viewModel.filteredItems(items)
        
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.map(\.productName), [
            "AirPods Later",
            "AirPods Soon"
        ])
    }
}

struct MockCertificate: CertificateRepresentableProtocol {
    let productName: String
    let validTo: Date
}
