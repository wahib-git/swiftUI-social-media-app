//
//  ParticipantEventDetailView.swift
//  social-media-app
//
//  Created by mac 3 on 25/11/2025.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ParticipantEventDetailView: View {
    let event: Event
    @State private var liveEvent: Event?
    @StateObject private var vm = ParticipantEventsViewModel()
    @State private var listener: ListenerRegistration?

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            VStack {
                // Carte stylée pour l'évènement
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "calendar.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                        Spacer()
                        Text((liveEvent?.status ?? event.status) == "open" ? "Ouvert" : "Fermé")
                            .font(.subheadline)
                            .padding(6)
                            .background((liveEvent?.status ?? event.status) == "open" ? Color.green.opacity(0.15) : Color.red.opacity(0.12))
                            .foregroundColor((liveEvent?.status ?? event.status) == "open" ? .green : .red)
                            .cornerRadius(6)
                    }

                    Text(liveEvent?.name ?? event.name)
                        .font(.title).bold().foregroundColor(.blue)
                    Text(liveEvent?.description ?? event.description)
                        .font(.body).foregroundColor(.gray)
                        .padding(.bottom, 2)

                    HStack {
                        Label(liveEvent?.location ?? event.location, systemImage: "mappin.and.ellipse")
                            .foregroundColor(.secondary)
                        Spacer()
                        Label("\(liveEvent?.participantsCount ?? event.participantsCount)/\(liveEvent?.maxParticipants ?? event.maxParticipants)",
                              systemImage: "person.3.fill")
                            .foregroundColor(.accentColor)
                            .font(.headline)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.07), radius: 8, y: 2)
                .padding(.horizontal)

                // Boutons stylés
                HStack(spacing: 18) {
                    Button {
                        Task {
                            if let uid = Auth.auth().currentUser?.uid, let id = event.id {
                                await vm.register(uid: uid, eventId: id)
                            }
                        }
                    } label: {
                        Label("S’inscrire", systemImage: "plus.circle")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .disabled((liveEvent?.status ?? event.status) != "open"
                              || (liveEvent?.participantsCount ?? event.participantsCount) >= (liveEvent?.maxParticipants ?? event.maxParticipants))

                    Button {
                        Task {
                            if let uid = Auth.auth().currentUser?.uid, let id = event.id {
                                await vm.unregister(uid: uid, eventId: id)
                            }
                        }
                    } label: {
                        Label("Se désinscrire", systemImage: "minus.circle")
                            .font(.headline)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .padding(.top, 10)

                // Affichage de l'erreur stylisé
                if let err = vm.error {
                    Text(err)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(8)
                        .background(Color(.systemRed).opacity(0.12))
                        .cornerRadius(6)
                        .padding(.top)
                }

                Spacer()
            }
            .padding(.top)
            .navigationTitle("Détail de l’évènement")
        }
        .onAppear { setupRealtimeListener(eventId: event.id) }
        .onDisappear { listener?.remove() }
    }

    func setupRealtimeListener(eventId: String?) {
        guard let eventId = eventId else { return }
        let db = Firestore.firestore()
        listener?.remove()
        listener = db.collection("events").document(eventId)
            .addSnapshotListener { snapshot, error in
                guard let snap = snapshot, let evt = try? snap.data(as: Event.self) else { return }
                DispatchQueue.main.async {
                    self.liveEvent = evt
                }
            }
    }
}
