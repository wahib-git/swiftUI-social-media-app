//
//  UserService.swift
//  social-media-app
//
//  Created by mac 3 on 5/11/2025.
//

import Foundation
import FirebaseFirestore

final class UserService {
    private let db = Firestore.firestore()

    func fetchUser(uid: String) async throws -> AppUser? {
        let snap = try await db.collection("users").document(uid).getDocument()
        return try snap.data(as: AppUser.self)
    }

    func createUserIfNeeded(uid: String, email: String) async throws {
        let ref = db.collection("users").document(uid)
        let snap = try await ref.getDocument()
        if snap.exists { return }
        let user = AppUser(id: uid, email: email, displayName: email, role: "participant", createdAt: nil)
        try ref.setData(from: user, merge: true)
    }
}
