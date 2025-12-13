//
//  FirebaseManager.swift
//  Task Flow Versiyon 2
//
//  Created on 13 Ekim 2025.
//

import Foundation

// MARK: - Mock User for Testing
struct MockUser: Codable, Equatable {
    let uid: String
    let email: String?
    var displayName: String?
    
    static func == (lhs: MockUser, rhs: MockUser) -> Bool {
        lhs.uid == rhs.uid
    }
    
    static let example = MockUser(
        uid: "mock-user-id",
        email: "test@example.com",
        displayName: "Test User"
    )
}