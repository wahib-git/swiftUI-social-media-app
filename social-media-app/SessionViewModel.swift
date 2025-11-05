//
//  SessionViewModel.swift
//  social-media-app
//
//  Created by mac 3 on 5/11/2025.
//

import Foundation
import Combine
import FirebaseAuth

@MainActor
final class SessionViewModel: ObservableObject {
    @Published var user: AppUser?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let auth = AuthService()
    let users = UserService()
    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { await self?.reloadProfile(firebaseUser: firebaseUser) }
        }
    }

    deinit {
        if let h = handle { Auth.auth().removeStateDidChangeListener(h) }
    }

    func reloadProfile(firebaseUser: User?) async {
        guard let u = firebaseUser else { self.user = nil; return }
        do {
            if let profile = try await users.fetchUser(uid: u.uid) { self.user = profile }
            else {
                try await users.createUserIfNeeded(uid: u.uid, email: u.email ?? "")
                self.user = try await users.fetchUser(uid: u.uid)
            }
        } catch { self.errorMessage = error.localizedDescription }
    }

    var isAdmin: Bool { user?.role == "admin" }

    func signIn(email: String, password: String) async {
        isLoading = true; defer { isLoading = false }
        do { try await auth.signIn(email: email, password: password) }
        catch { errorMessage = error.localizedDescription }
    }

    func signUp(email: String, password: String) async {
        isLoading = true; defer { isLoading = false }
        do { try await auth.signUp(email: email, password: password) }
        catch { errorMessage = error.localizedDescription }
    }

    func signOut() {
        do { try auth.signOut() } catch { errorMessage = error.localizedDescription }
    }
}
