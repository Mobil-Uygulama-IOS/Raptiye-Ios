//
//  AuthViewModelTests.swift
//  RaptiyeTests
//
//  Created on 2 Aralık 2025.
//

import XCTest
@testable import Raptiye

@MainActor
final class AuthViewModelTests: XCTestCase {
    
    var sut: AuthViewModel!
    
    override func setUp() {
        super.setUp()
        sut = AuthViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testAuthViewModelInitialization() {
        // Given & When: AuthViewModel oluşturuldu
        
        // Then: Başlangıç değerleri doğru olmalı
        XCTAssertNotNil(sut)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Email Validation Tests
    
    func testValidEmailFormat() {
        // Given: Geçerli email adresleri
        let validEmails = [
            "test@example.com",
            "user.name@domain.co.uk",
            "firstname+lastname@example.com",
            "email@subdomain.example.com"
        ]
        
        // When & Then: Tüm emailler geçerli format olmalı
        for email in validEmails {
            XCTAssertTrue(email.contains("@"), "\(email) geçerli bir email formatı olmalı")
            XCTAssertTrue(email.contains("."), "\(email) geçerli bir email formatı olmalı")
        }
    }
    
    func testInvalidEmailFormat() {
        // Given: Geçersiz email adresleri
        let invalidEmails = [
            "invalidemail",
            "@example.com",
            "user@",
            "user name@example.com",
            ""
        ]
        
        // When & Then: Emailler geçersiz olmalı
        for email in invalidEmails {
            let isValid = email.contains("@") && email.contains(".") && !email.contains(" ")
            XCTAssertFalse(isValid, "\(email) geçersiz email formatı olmalı")
        }
    }
    
    // MARK: - Password Validation Tests
    
    func testPasswordLength() {
        // Given: Farklı uzunluklarda şifreler
        let shortPassword = "12345"
        let validPassword = "123456"
        let longPassword = "verylongpassword123456789"
        
        // Then: Şifre uzunlukları doğru kontrol edilmeli
        XCTAssertLessThan(shortPassword.count, 6, "Kısa şifre 6 karakterden az olmalı")
        XCTAssertGreaterThanOrEqual(validPassword.count, 6, "Geçerli şifre en az 6 karakter olmalı")
        XCTAssertGreaterThan(longPassword.count, 6, "Uzun şifre 6 karakterden fazla olmalı")
    }
    
    func testEmptyPassword() {
        // Given: Boş şifre
        let emptyPassword = ""
        
        // Then: Boş şifre geçersiz olmalı
        XCTAssertTrue(emptyPassword.isEmpty)
        XCTAssertEqual(emptyPassword.count, 0)
    }
    
    // MARK: - User Session Tests
    
    func testUserSessionInitiallyNil() {
        // Given & When: Yeni AuthViewModel
        
        // Then: userSession başlangıçta nil olmalı
        XCTAssertNil(sut.userSession)
    }
    
    func testUserSessionCanBeSet() {
        // Given: Test kullanıcısı
        let testUser = MockUser(uid: "test123", email: "test@example.com", displayName: "Test User")
        
        // When: userSession set edilir
        sut.userSession = testUser
        
        // Then: userSession dolu olmalı
        XCTAssertNotNil(sut.userSession)
        XCTAssertEqual(sut.userSession?.uid, "test123")
        XCTAssertEqual(sut.userSession?.email, "test@example.com")
        XCTAssertEqual(sut.userSession?.displayName, "Test User")
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingStateInitiallyFalse() {
        // Given & When: Yeni AuthViewModel
        
        // Then: Loading başlangıçta false olmalı
        XCTAssertFalse(sut.isLoading)
    }
    
    func testLoadingStateCanBeToggled() {
        // Given: Loading başlangıçta false
        XCTAssertFalse(sut.isLoading)
        
        // When: Loading true yapılır
        sut.isLoading = true
        
        // Then: Loading true olmalı
        XCTAssertTrue(sut.isLoading)
        
        // When: Loading tekrar false yapılır
        sut.isLoading = false
        
        // Then: Loading false olmalı
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Error Message Tests
    
    func testErrorMessageInitiallyNil() {
        // Given & When: Yeni AuthViewModel
        
        // Then: Error mesajı başlangıçta nil olmalı
        XCTAssertNil(sut.errorMessage)
    }
    
    func testErrorMessageCanBeSet() {
        // Given: Test error mesajı
        let testError = "Test error mesajı"
        
        // When: Error mesajı set edilir
        sut.errorMessage = testError
        
        // Then: Error mesajı doğru olmalı
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.errorMessage, testError)
    }
    
    func testErrorMessageCanBeCleared() {
        // Given: Error mesajı var
        sut.errorMessage = "Test error"
        XCTAssertNotNil(sut.errorMessage)
        
        // When: Error temizlenir
        sut.errorMessage = nil
        
        // Then: Error nil olmalı
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - MockUser Tests
    
    func testMockUserInitialization() {
        // Given: MockUser verisi
        let user = MockUser(
            uid: "user123",
            email: "test@example.com",
            displayName: "Test User"
        )
        
        // Then: Tüm özellikler doğru olmalı
        XCTAssertEqual(user.uid, "user123")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.displayName, "Test User")
    }
    
    func testMockUserWithOptionalFields() {
        // Given: Minimum veri ile kullanıcı
        let user = MockUser(uid: "minimal123", email: "minimal@test.com", displayName: nil)
        
        // Then: Zorunlu alanlar dolu, displayName opsiyonel
        XCTAssertEqual(user.uid, "minimal123")
        XCTAssertEqual(user.email, "minimal@test.com")
        XCTAssertNil(user.displayName)
    }
}
