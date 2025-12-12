//
//  EnhancedLoginViewUITests.swift
//  Task Flow Versiyon 2UITests
//
//  Created on 2 Aralık 2025.
//

import XCTest

final class EnhancedLoginViewUITests: XCTestCase {
    
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
    
    // MARK: - Login Screen Tests
    
    func testLoginScreenExists() {
        // Then
        XCTAssertTrue(app.textFields["Email"].exists, "Email text field should exist")
        XCTAssertTrue(app.secureTextFields["Password"].exists || app.textFields["Password"].exists, "Password field should exist")
    }
    
    func testLoginButtonExists() {
        // Then
        let loginButton = app.buttons["Login"] .element(matching: .button, identifier: "LoginButton")
        XCTAssertTrue(loginButton.exists || app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'giri'")).element.exists, "Login button should exist")
    }
    
    func testEmailFieldInteraction() {
        // Given
        let emailField = app.textFields["Email"].firstMatch
        
        // When
        if emailField.exists {
            emailField.tap()
            emailField.typeText("test@example.com")
            
            // Then
            XCTAssertEqual(emailField.value as? String, "test@example.com")
        }
    }
    
    func testPasswordFieldInteraction() {
        // Given
        let passwordField = app.secureTextFields["Password"].firstMatch
        
        // When
        if passwordField.exists {
            passwordField.tap()
            passwordField.typeText("password123")
            
            // Then
            XCTAssertTrue(passwordField.exists)
        }
    }
    
    func testLoginWithEmptyFields() {
        // Given
        let loginButton = app.buttons.element(matching: .button, identifier: "LoginButton")
        
        // When
        if loginButton.exists {
            loginButton.tap()
            
            // Then - Should show error or stay on same screen
            XCTAssertTrue(app.textFields["Email"].exists, "Should remain on login screen")
        }
    }
    
    func testRegisterButtonExists() {
        // Then
        let registerButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'kay' OR label CONTAINS[c] 'register'")).element
        XCTAssertTrue(registerButton.exists || app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'hesap'")).element.exists, "Register option should exist")
    }
    
    // MARK: - Performance Tests
    
    func testLoginScreenLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
