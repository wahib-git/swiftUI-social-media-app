//
//  ParticipantHomeView.swift
//  social-media-app
//
//  Created by mac 3 on 5/11/2025.
//
import SwiftUI
import FirebaseAuth

struct ParticipantHomeView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var vm = ParticipantEventsViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.events) { e in
                    NavigationLink(destination: ParticipantEventDetailView(event: e)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(e.name).font(.headline)
                                Text(e.location).font(.subheadline).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(e.participantsCount)/\(e.maxParticipants)")
                                .monospacedDigit().foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                        .transition(.move(edge: .trailing))
                    }
                }
            }
            .navigationTitle("Événements")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Déconnexion") { session.signOut() } }
            }
            .task { await vm.load() }
        }
    }
}

struct ParticipantEventDetailView: View {
    let event: Event
    @StateObject private var vm = ParticipantEventsViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(event.name).font(.title2).bold()
            Text(event.description)
            Text("Lieu: \(event.location)")
            Text("Places: \(event.participantsCount)/\(event.maxParticipants)")

            HStack {
                Button("S’inscrire") {
                    Task {
                        if let uid = Auth.auth().currentUser?.uid, let id = event.id {
                            await vm.register(uid: uid, eventId: id)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(event.status != "open" || event.participantsCount >= event.maxParticipants)

                Button("Se désinscrire") {
                    Task {
                        if let uid = Auth.auth().currentUser?.uid, let id = event.id {
                            await vm.unregister(uid: uid, eventId: id)
                        }
                    }
                }
                .buttonStyle(.bordered)
            }

            if let err = vm.error { Text(err).foregroundStyle(.red) }
            Spacer()
        }
        .padding()
        .navigationTitle("Détail")
    }
}
