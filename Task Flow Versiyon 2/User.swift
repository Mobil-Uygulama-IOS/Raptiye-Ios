//
//  User.swift
//  Raptiye
//
//  Created on 16 Ekim 2025.
//

import Foundation

/// Kullanıcı modeli - Android User.kt ile aynı
struct User: Identifiable, Codable {
    let uid: String
    let displayName: String?
    let email: String?
    let photoUrl: String?
    let createdAt: Date?
    
    var id: String { uid }
    
    /// Kullanıcı initials (ilk harf)
    var initials: String {
        if let name = displayName, let first = name.first {
            return String(first).uppercased()
        }
        return "U"
    }
    
    enum CodingKeys: String, CodingKey {
        case uid
        case displayName
        case email
        case photoUrl
        case createdAt
    }
    
    init(uid: String, displayName: String? = nil, email: String? = nil, photoUrl: String? = nil, createdAt: Date? = nil) {
        self.uid = uid
        self.displayName = displayName
        self.email = email
        self.photoUrl = photoUrl
        self.createdAt = createdAt
    }
    
    /// Örnek kullanıcılar
    static let sampleUsers = [
        User(uid: "1", displayName: "Emily Carter", email: "emily@example.com"),
        User(uid: "2", displayName: "David Lee", email: "david@example.com"),
        User(uid: "3", displayName: "Ahmet Yılmaz", email: "ahmet@example.com"),
        User(uid: "4", displayName: "Ayşe Demir", email: "ayse@example.com")
    ]
}
