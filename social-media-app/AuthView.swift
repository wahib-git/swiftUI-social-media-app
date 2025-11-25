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
    @Namespace private var animation // Pour l'animation matched geometry

    var body: some View {
        ZStack {
            // Dégradé bleu pour tout le fond, pas de blanc
            LinearGradient(gradient:
                Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.6)]),
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            VStack {
                Spacer()
                ZStack {
                    // Animation lors du switch login/register
                    Group {
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.white)
                                Spacer()
                            }

                            Text("Community Events")
                                .font(.largeTitle).bold()
                                .foregroundColor(.white)
                                .padding(.bottom, 2)
                                .matchedGeometryEffect(id: "title", in: animation)

                            Group {
                                TextField("Email", text: $email)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                                    .autocorrectionDisabled()
                                    .padding()
                                    .background(Color.white.opacity(0.18))
                                    .cornerRadius(10)
                                SecureField("Mot de passe", text: $password)
                                    .padding()
                                    .background(Color.white.opacity(0.18))
                                    .cornerRadius(10)
                            }
                            .foregroundColor(.white)
                            .font(.headline)

                            if session.isLoading { ProgressView().tint(.green) }

                            Button {
                                Task {
                                    if isSignUp { await session.signUp(email: email, password: password) }
                                    else { await session.signIn(email: email, password: password) }
                                }
                            } label: {
                                Label(isSignUp ? "Créer un compte" : "Se connecter",
                                      systemImage: isSignUp ? "person.crop.circle.badge.plus" : "arrow.right.circle")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            .shadow(color: .white.opacity(0.10), radius: 4, y: 2)
                            .disabled(email.isEmpty || password.isEmpty)
                            .padding(.vertical, 6)

                            Button(isSignUp ? "J’ai déjà un compte" : "Créer un compte") {
                                withAnimation(.easeInOut) { isSignUp.toggle() }
                            }
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .padding(.bottom, 2)

                            if let err = session.errorMessage {
                                Text(err)
                                    .foregroundColor(.red)
                                    .padding(8)
                                    .background(Color(.systemRed).opacity(0.14))
                                    .cornerRadius(8)
                                    .font(.subheadline)
                            }
                        }
                        .padding(30)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.1))
                            .shadow(color: Color.black.opacity(0.11), radius: 16, y: 4)
                    )
                    .scaleEffect(isSignUp ? 1.04 : 1.0)
                    .opacity(isSignUp ? 0.97 : 1.0)
                    .animation(.spring(response: 0.44, dampingFraction: 0.8), value: isSignUp)
                    .transition(.scale.combined(with: .opacity))
                }
                .padding(.horizontal, 22)
                Spacer()
            }
        }
    }
}
