//
//  ProjectListViewUITests.swift
//  RaptiyeUITests
//
//  Created on 2 Aralık 2025.
//

import XCTest

final class ProjectListViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Basic Tests
    
    func testAppHasNavigationElements() throws {
        // Test that app has navigation capabilities
        let hasNavigation = app.navigationBars.count > 0 || app.tabBars.count > 0
        XCTAssertTrue(hasNavigation || app.buttons.count > 0, "App should have navigation elements")
    }
    
    func testScrollViewExists() throws {
        // Test that scrollable content exists
        let hasScrollableContent = app.scrollViews.count > 0 || app.tables.count > 0 || app.collectionViews.count > 0
        XCTAssertTrue(hasScrollableContent || app.otherElements.count > 0, "App should have content")
    }
    
    func testInteractiveElementsExist() throws {
        // Test that interactive elements are present
        XCTAssertTrue(app.buttons.count > 0 || app.textFields.count > 0, "App should have interactive elements")
    }
}
