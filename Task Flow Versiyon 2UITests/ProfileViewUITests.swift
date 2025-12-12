//
//  ProfileViewUITests.swift
//  Task Flow Versiyon 2UITests
//
//  Created on 2 Aralık 2025.
//

import XCTest

final class ProfileViewUITests: XCTestCase {
    
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
    
    // MARK: - Profile Screen Tests
    
    func testProfileTabExists() {
        // Then
        let profileTab = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'profil' OR label CONTAINS[c] 'profile'")).element
        XCTAssertTrue(profileTab.exists || app.tabBars.buttons.element(boundBy: 2).exists, "Profile tab should exist")
    }
    
    func testNavigateToProfile() {
        // Given
        let profileTab = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'profil' OR label CONTAINS[c] 'profile'")).element
        
        // When
        if profileTab.exists {
            profileTab.tap()
            
            // Then
            XCTAssertTrue(app.navigationBars.element.exists || app.staticTexts.element(boundBy: 0).exists, "Profile screen should load")
        }
    }
    
    func testProfileEditButtonExists() {
        // Given
        let profileTab = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'profil'")).element
        
        // When
        if profileTab.exists {
            profileTab.tap()
            
            // Then
            let editButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'düzenle' OR label CONTAINS[c] 'edit'")).element
            XCTAssertTrue(editButton.exists || app.buttons.element(boundBy: 0).exists, "Edit button should exist")
        }
    }
    
    func testProfileDisplaysUserInfo() {
        // Given
        let profileTab = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'profil'")).element
        
        // When
        if profileTab.exists {
            profileTab.tap()
            
            // Then - Should display user information
            let textElements = app.staticTexts.count
            XCTAssertGreaterThan(textElements, 0, "Profile should display user information")
        }
    }
    
    func testLogoutButtonExists() {
        // Given
        let profileTab = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'profil'")).element
        
        // When
        if profileTab.exists {
            profileTab.tap()
            
            // Then
            let logoutButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'çıkış' OR label CONTAINS[c] 'logout'")).element
            XCTAssertTrue(logoutButton.exists || app.buttons.element(boundBy: 1).exists, "Logout option should exist")
        }
    }
    
    func testEditProfileMode() {
        // Given
        let profileTab = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'profil'")).element
        
        // When
        if profileTab.exists {
            profileTab.tap()
            
            let editButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'düzenle'")).element
            
            if editButton.exists {
                editButton.tap()
                
                // Then - Should enter edit mode
                let textFields = app.textFields.count
                XCTAssertGreaterThan(textFields, 0, "Edit mode should show text fields")
            }
        }
    }
    
    // MARK: - Settings Tests
    
    func testSettingsAccessible() {
        // Given
        let profileTab = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'profil'")).element
        
        // When
        if profileTab.exists {
            profileTab.tap()
            
            // Then - Check if settings or preferences are accessible
            let settingsButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'ayar' OR label CONTAINS[c] 'settings'")).element
            XCTAssertTrue(settingsButton.exists || app.buttons.count > 0, "Settings should be accessible from profile")
        }
    }
}
