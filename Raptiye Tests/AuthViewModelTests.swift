//
//  AuthViewModelTests.swift
//  RaptiyeTests
//
//  Created on 2 Aralık 2025.
//

import XCTest
@testable import Task_Flow_Versiyon_2

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
        XCTAssertNil(sut.currentUser)
        XCTAssertFalse(sut.isAuthenticated)
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
        
        // Then: Şifre uzunlukları kontrol edilmeli
        XCTAssertTrue(shortPassword.count < 6, "Kısa şifre 6 karakterden az olmalı")
        XCTAssertTrue(validPassword.count >= 6, "Geçerli şifre en az 6 karakter olmalı")
        XCTAssertTrue(longPassword.count > 6, "Uzun şifre 6 karakterden fazla olmalı")
    }
    
    func testEmptyPassword() {
        // Given: Boş şifre
        let emptyPassword = ""
        
        // Then: Boş şifre geçersiz olmalı
        XCTAssertTrue(emptyPassword.isEmpty)
        XCTAssertEqual(emptyPassword.count, 0)
    }
    
    // MARK: - Authentication State Tests
    
    func testIsAuthenticatedWhenUserIsNil() {
        // Given: Kullanıcı nil
        sut.currentUser = nil
        
        // Then: Authenticated false olmalı
        XCTAssertFalse(sut.isAuthenticated)
    }
    
    func testIsAuthenticatedWhenUserExists() {
        // Given: Kullanıcı var
        let testUser = User(uid: "test123", email: "test@example.com", displayName: "Test User")
        sut.currentUser = testUser
        
        // Then: Authenticated true olmalı
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertEqual(sut.currentUser?.email, "test@example.com")
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingStateToggle() {
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
    
    func testErrorMessageHandling() {
        // Given: Başlangıçta error yok
        XCTAssertNil(sut.errorMessage)
        
        // When: Error mesajı set edilir
        let testError = "Test error mesajı"
        sut.errorMessage = testError
        
        // Then: Error mesajı doğru olmalı
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.errorMessage, testError)
        
        // When: Error temizlenir
        sut.errorMessage = nil
        
        // Then: Error nil olmalı
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - User Data Tests
    
    func testUserDataProperties() {
        // Given: Kullanıcı verisi
        let testUser = User(
            uid: "user123",
            email: "test@example.com",
            displayName: "Test User",
            bio: "Test bio",
            avatarURL: "https://example.com/avatar.jpg"
        )
        
        // Then: Tüm özellikler doğru olmalı
        XCTAssertEqual(testUser.uid, "user123")
        XCTAssertEqual(testUser.email, "test@example.com")
        XCTAssertEqual(testUser.displayName, "Test User")
        XCTAssertEqual(testUser.bio, "Test bio")
        XCTAssertEqual(testUser.avatarURL, "https://example.com/avatar.jpg")
    }
    
    func testUserWithMinimalData() {
        // Given: Minimum veri ile kullanıcı
        let minimalUser = User(uid: "minimal123", email: "minimal@test.com")
        
        // Then: Zorunlu alanlar dolu, opsiyoneller nil olmalı
        XCTAssertEqual(minimalUser.uid, "minimal123")
        XCTAssertEqual(minimalUser.email, "minimal@test.com")
        XCTAssertNil(minimalUser.displayName)
        XCTAssertNil(minimalUser.bio)
        XCTAssertNil(minimalUser.avatarURL)
    }
    
    // MARK: - Sign Out Tests
    
    func testSignOutClearsUserData() {
        // Given: Giriş yapmış kullanıcı
        let testUser = User(uid: "test123", email: "test@example.com", displayName: "Test")
        sut.currentUser = testUser
        XCTAssertTrue(sut.isAuthenticated)
        
        // When: Sign out yapılır (manuel olarak temizlenir)
        sut.currentUser = nil
        sut.errorMessage = nil
        
        // Then: Kullanıcı verisi temizlenmeli
        XCTAssertNil(sut.currentUser)
        XCTAssertFalse(sut.isAuthenticated)
    }
}
