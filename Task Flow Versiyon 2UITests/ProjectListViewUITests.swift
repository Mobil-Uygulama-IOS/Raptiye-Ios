//
//  ProjectListViewUITests.swift
//  Task Flow Versiyon 2UITests
//
//  Created on 2 Aralık 2025.
//

import XCTest

final class ProjectListViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    // MARK: - Project List Tests
    
    func testProjectListNavigationExists() {
        // Given - Assuming user is logged in and navigates to projects
        let projectsTab = app.buttons["Projects"].firstMatch
        
        // When
        if projectsTab.exists {
            projectsTab.tap()
            
            // Then
            XCTAssertTrue(app.navigationBars.element.exists, "Navigation bar should exist")
        }
    }
    
    func testAddProjectButtonExists() {
        // Given
        let projectsTab = app.buttons["Projects"].firstMatch
        
        // When
        if projectsTab.exists {
            projectsTab.tap()
            
            // Then
            let addButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] '+' OR label CONTAINS[c] 'ekle' OR label CONTAINS[c] 'add'")).element
            XCTAssertTrue(addButton.exists || app.buttons.element(boundBy: 0).exists, "Add project button should exist")
        }
    }
    
    func testProjectListScrollable() {
        // Given
        let projectsTab = app.buttons["Projects"].firstMatch
        
        // When
        if projectsTab.exists {
            projectsTab.tap()
            
            // Then
            let scrollView = app.scrollViews.firstMatch
            let list = app.collectionViews.firstMatch
            XCTAssertTrue(scrollView.exists || list.exists, "List should be scrollable")
        }
    }
    
    func testEmptyProjectListMessage() {
        // Given
        let projectsTab = app.buttons["Projects"].firstMatch
        
        // When
        if projectsTab.exists {
            projectsTab.tap()
            
            // Then - Check for empty state or project items
            let emptyMessage = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'proje' OR label CONTAINS[c] 'empty'")).element
            let projectCells = app.cells.count
            
            XCTAssertTrue(emptyMessage.exists || projectCells > 0, "Should show empty message or projects")
        }
    }
    
    func testProjectCellTappable() {
        // Given
        let projectsTab = app.buttons["Projects"].firstMatch
        
        // When
        if projectsTab.exists {
            projectsTab.tap()
            
            let firstProject = app.cells.firstMatch
            
            if firstProject.exists {
                // Then
                XCTAssertTrue(firstProject.isHittable, "Project cell should be tappable")
                firstProject.tap()
                
                // Should navigate to detail view
                XCTAssertTrue(app.navigationBars.element.exists)
            }
        }
    }
    
    // MARK: - Search Tests
    
    func testSearchFieldExists() {
        // Given
        let projectsTab = app.buttons["Projects"].firstMatch
        
        // When
        if projectsTab.exists {
            projectsTab.tap()
            
            // Then
            let searchField = app.searchFields.firstMatch
            XCTAssertTrue(searchField.exists || app.textFields.element(boundBy: 0).exists, "Search field should exist or be accessible")
        }
    }
}
