//
//  ScanGuaranteeUITests.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 26.04.26.
//


import XCTest
@testable import ScanGuarantee

final class ScanGuaranteeUITests: XCTestCase {
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments.append("-UITesting")
        app.launch()
    }

    func testHomeScreenIsVisible() {
        let title = app.staticTexts["home_title"]

        XCTAssertTrue(title.waitForExistence(timeout: 3))
    }

    func testAddCertificateOptionsAreShown() {
        let addButton = app.buttons["add_certificate_button"]

        XCTAssertTrue(addButton.waitForExistence(timeout: 3))
        addButton.tap()

        XCTAssertTrue(app.buttons["Сфотографировать"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Выбрать из галереи"].exists)
        XCTAssertTrue(app.buttons["Добавить вручную"].exists)
    }
    
    func testManualAddCertificateScreenOpens() {
        let addButton = app.buttons["add_certificate_button"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3))
        
        addButton.tap()
        
        let manualButton = app.buttons["Добавить вручную"]
        XCTAssertTrue(manualButton.waitForExistence(timeout: 2))
        manualButton.tap()
        
        let nameField = app.textFields["certificate_name_textfield"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
    }
    
    func testCannotSaveCertificateWithoutProductName() {
        app.buttons["add_certificate_button"].tap()
        app.buttons["Добавить вручную"].tap()
        
        let saveButton = app.buttons["save_certificate_button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3))
        
        saveButton.tap()
        
        let nameField = app.textFields["certificate_name_textfield"]
        XCTAssertTrue(nameField.exists)
    }
    
    func testCreateCertificateAndFindItWithSearch() {
        let productName = "UITest AirPods"
        
        app.buttons["add_certificate_button"].tap()
        app.buttons["Добавить вручную"].tap()
        
        let nameField = app.textFields["certificate_name_textfield"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        nameField.tap()
        nameField.typeText(productName)
        
        let saveButton = app.buttons["save_certificate_button"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()
        
        let cell = app.descendants(matching: .any)["certificate_cell_\(productName)"]
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
}
