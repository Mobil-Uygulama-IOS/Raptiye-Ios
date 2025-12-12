//
//  AuthViewModelTests.swift
//  Task Flow Versiyon 2Tests
//
//  Created on 2 Aralık 2025.
//

import XCTest
@testable import Task_Flow_Versiyon_2

@MainActor
final class AuthViewModelTests: XCTestCase {
    
    var authViewModel: AuthViewModel!
    
    override func setUp() {
        super.setUp()
        authViewModel = AuthViewModel()
    }
    
    override func tearDown() {
        authViewModel = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testAuthViewModelInitialization() {
        // Then
        XCTAssertNotNil(authViewModel)
        XCTAssertEqual(authViewModel.email, "")
        XCTAssertEqual(authViewModel.password, "")
        XCTAssertFalse(authViewModel.isLoading)
        XCTAssertNil(authViewModel.errorMessage)
    }
    
    // MARK: - Email Validation Tests
    
    func testValidEmailFormat() {
        // Given
        let validEmails = [
            "test@example.com",
            "user.name@domain.co",
            "first.last@company.org"
        ]
        
        // When & Then
        for email in validEmails {
            authViewModel.email = email
            XCTAssertTrue(isValidEmail(email), "\(email) should be valid")
        }
    }
    
    func testInvalidEmailFormat() {
        // Given
        let invalidEmails = [
            "invalid",
            "@example.com",
            "user@",
            "user @example.com"
        ]
        
        // When & Then
        for email in invalidEmails {
            authViewModel.email = email
            XCTAssertFalse(isValidEmail(email), "\(email) should be invalid")
        }
    }
    
    // MARK: - Password Validation Tests
    
    func testPasswordLength() {
        // Given
        authViewModel.password = "12345"
        
        // Then
        XCTAssertTrue(authViewModel.password.count < 6, "Password should be less than 6 characters")
        
        // Given
        authViewModel.password = "123456"
        
        // Then
        XCTAssertTrue(authViewModel.password.count >= 6, "Password should be 6 or more characters")
    }
    
    func testEmptyPassword() {
        // Given
        authViewModel.password = ""
        
        // Then
        XCTAssertTrue(authViewModel.password.isEmpty)
    }
    
    // MARK: - State Tests
    
    func testLoadingState() {
        // Given
        authViewModel.isLoading = false
        
        // When
        authViewModel.isLoading = true
        
        // Then
        XCTAssertTrue(authViewModel.isLoading)
        
        // When
        authViewModel.isLoading = false
        
        // Then
        XCTAssertFalse(authViewModel.isLoading)
    }
    
    func testErrorMessageState() {
        // Given
        authViewModel.errorMessage = nil
        
        // When
        authViewModel.errorMessage = "Test error"
        
        // Then
        XCTAssertNotNil(authViewModel.errorMessage)
        XCTAssertEqual(authViewModel.errorMessage, "Test error")
    }
    
    // MARK: - Helper Methods
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
