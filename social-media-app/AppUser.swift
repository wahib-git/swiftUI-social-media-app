//
//  AppUser.swift
//  social-media-app
//
//  Created by mac 3 on 5/11/2025.
//
import Foundation
import FirebaseFirestore

struct AppUser: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var displayName: String
    var role: String // "admin" | "participant"
    @ServerTimestamp var createdAt: Date?
}
