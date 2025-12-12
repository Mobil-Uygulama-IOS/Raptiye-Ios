//
//  EnhancedLoginViewUITests.swift
//  RaptiyeUITests
//
//  Created on 2 Aralık 2025.
//

import XCTest

final class EnhancedLoginViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Basic UI Tests
    
    func testAppLaunches() throws {
        // Test that app launches successfully
        XCTAssertTrue(app.exists, "App should launch")
    }
    
    func testLoginScreenDisplays() throws {
        // Test that login screen elements are visible
        let exists = app.staticTexts["Raptiye"].exists || app.images.firstMatch.exists
        XCTAssertTrue(exists, "Login screen should display")
    }
    
    func testTextFieldsExist() throws {
        // Test that input fields exist
        let textFieldsCount = app.textFields.count
        let secureFieldsCount = app.secureTextFields.count
        XCTAssertTrue(textFieldsCount > 0 || secureFieldsCount > 0, "Input fields should exist")
    }
    
    func testButtonsExist() throws {
        // Test that buttons exist on screen
        XCTAssertTrue(app.buttons.count > 0, "Buttons should exist on login screen")
    }
    
    // MARK: - Performance Test
    
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
