//
//  AdminHomeView.swift
//  social-media-app
//
//  Created by mac 3 on 5/11/2025.
//

import SwiftUI
import FirebaseAuth

struct AdminHomeView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var vm = AdminEventsViewModel()
    @State private var showEditor = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.events) { e in
                    NavigationLink(destination: AdminEventDetailView(event: e)) {
                        VStack(alignment: .leading) {
                            Text(e.name).font(.headline)
                            Text("\(e.location) • \(e.participantsCount)/\(e.maxParticipants)")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { idx in
                    Task { for i in idx { if let id = vm.events[i].id { await vm.delete(id: id) } } }
                }
            }
            .navigationTitle("Événements (Admin)")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Déconnexion") { session.signOut() } }
                ToolbarItem(placement: .primaryAction) {
                    Button { withAnimation(.spring()) { showEditor = true } } label: {
                        Image(systemName: "plus.circle.fill").font(.title2)
                    }
                }
            }
            .task { await vm.load() }
            .sheet(isPresented: $showEditor) {
                AdminEventEditor { newEvent in
                    Task {
                        guard let uid = session.user?.id ?? Auth.auth().currentUser?.uid else { return }
                        var e = newEvent
                        e.createdBy = uid
                        await vm.create(event: e)
                        showEditor = false
                    }
                }
            }
        }
    }
}

struct AdminEventEditor: View {
    var onSave: (Event) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var location = ""
    @State private var maxParticipants = 20
    @State private var date = Date().addingTimeInterval(72*3600)
    @State private var startDate = Date()
    @State private var imageURL = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Infos") {
                    TextField("Nom", text: $name)
                    TextField("Description", text: $description)
                    TextField("Lieu", text: $location)
                    TextField("Image URL (optionnel)", text: $imageURL)
                }
                Section("Dates et capacités") {
                    DatePicker("Début", selection: $startDate)
                    DatePicker("Date", selection: $date)
                    Stepper("Places max: \(maxParticipants)", value: $maxParticipants, in: 1...500)
                }
            }
            .navigationTitle("Nouvel évènement")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Annuler") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        let e = Event(id: nil,
                            name: name.isEmpty ? "Évènement" : name,
                            description: description,
                            date: date,
                            startDate: startDate,
                            maxParticipants: maxParticipants,
                            location: location,
                            imageURL: imageURL.isEmpty ? nil : imageURL,
                            status: "open",
                            participantsCount: 0,
                            createdBy: "",
                            createdAt: nil,
                            updatedAt: nil)
                        onSave(e)
                    }
                    .disabled(name.isEmpty || location.isEmpty)
                }
            }
        }
    }
}

struct AdminEventDetailView: View {
    let event: Event
    var body: some View {
        List {
            Section("Détails") {
                Text(event.description)
                Text("Lieu: \(event.location)")
                Text("Statut: \(event.status)")
                Text("Capacité: \(event.participantsCount)/\(event.maxParticipants)")
            }
        }
        .navigationTitle(event.name)
    }
}
