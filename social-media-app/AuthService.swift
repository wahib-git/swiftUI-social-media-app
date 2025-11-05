//
//  AuthService.swift
//  social-media-app
//
//  Created by mac 3 on 5/11/2025.
//

import Foundation
import FirebaseAuth

final class AuthService {
    func currentUser() -> User? { Auth.auth().currentUser }

    func signIn(email: String, password: String) async throws {
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        _ = try await Auth.auth().createUser(withEmail: email, password: password)
    }

    func signOut() throws { try Auth.auth().signOut() }
}
