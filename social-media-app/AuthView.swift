//
//  AuthView.swift
//  social-media-app
//
//  Created by mac 3 on 5/11/2025.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var session: SessionViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Community Events").font(.largeTitle).bold().transition(.scale)
            TextField("Email", text: $email).textInputAutocapitalization(.never).textFieldStyle(.roundedBorder)
            SecureField("Mot de passe", text: $password).textFieldStyle(.roundedBorder)
            if session.isLoading { ProgressView() }
            Button(isSignUp ? "Créer un compte" : "Se connecter") {
                Task {
                    if isSignUp { await session.signUp(email: email, password: password) }
                    else { await session.signIn(email: email, password: password) }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(email.isEmpty || password.isEmpty)
            .animation(.spring(), value: isSignUp)

            Button(isSignUp ? "J’ai déjà un compte" : "Créer un compte") {
                withAnimation(.spring()) { isSignUp.toggle() }
            }
            if let err = session.errorMessage { Text(err).foregroundStyle(.red) }
        }
        .padding()
    }
}
