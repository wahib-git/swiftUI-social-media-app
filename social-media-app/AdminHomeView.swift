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
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                        Text("Dashboard admin")
                            .font(.title2).bold().foregroundColor(.blue)
                        Spacer()
                        Button(action: { session.signOut() }) {
                            Label("Déconnexion", systemImage: "arrowshape.turn.up.left")
                                .labelStyle(.iconOnly)
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                        Button {
                            withAnimation(.spring()) { showEditor = true }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2).foregroundColor(.green)
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(vm.events) { e in
                                NavigationLink(destination: AdminEventDetailView(event: e)) {
                                    AdminEventCard(event: e)
                                }
                                .buttonStyle(.plain)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                            .onDelete { idx in
                                Task {
                                    for i in idx {
                                        if let id = vm.events[i].id { await vm.delete(id: id) }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 6)
                        .padding(.bottom, 16)
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

// Carte stylée pour l’admin
struct AdminEventCard: View {
    let event: Event
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.blue)
                Spacer()
                Text(event.status == "open" ? "Ouvert" : "Fermé")
                    .font(.caption)
                    .foregroundColor(event.status == "open" ? .green : .red)
                    .padding(5)
                    .background(event.status == "open" ? Color.green.opacity(0.13) : Color.red.opacity(0.13))
                    .cornerRadius(8)
            }
            Text(event.name)
                .font(.headline).bold().foregroundColor(.blue)
            Text(event.description)
                .font(.subheadline).foregroundColor(.gray).lineLimit(2)
            HStack {
                Label("\(event.location)", systemImage: "mappin.and.ellipse")
                    .font(.footnote).foregroundColor(.secondary)
                Spacer()
                Label("\(event.participantsCount)/\(event.maxParticipants)", systemImage: "person.fill")
                    .font(.footnote).foregroundColor(.accentColor)
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(16)
        .shadow(color: Color.blue.opacity(0.07), radius: 6, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(event.status == "open" ? Color.green : Color.red, lineWidth: 1)
        )
        .padding(.vertical, 2)
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
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            VStack {
                Spacer()
                VStack(spacing: 20) {
                    Text("Créer/modifier un évènement")
                        .font(.title2).bold()
                        .foregroundColor(.blue)
                    Group {
                        TextField("Nom", text: $name)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)

                        TextField("Description", text: $description)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)

                        TextField("Lieu", text: $location)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)

                        TextField("Image URL (optionnel)", text: $imageURL)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        DatePicker("Début", selection: $startDate)
                            .padding(8)
                            .background(Color(.systemGray5))
                            .cornerRadius(12)

                        DatePicker("Date de fin", selection: $date)
                            .padding(8)
                            .background(Color(.systemGray5))
                            .cornerRadius(12)

                        Stepper("Places max: \(maxParticipants)", value: $maxParticipants, in: 1...500)
                            .padding(8)
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                    }

                    HStack(spacing: 20) {
                        Button("Annuler") { dismiss() }
                            .buttonStyle(.bordered)
                            .tint(.gray)

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
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .disabled(name.isEmpty || location.isEmpty)
                    }
                    .padding(.top, 10)
                }
                .padding(28)
                .background(Color.white)
                .cornerRadius(22)
                .shadow(color: Color.black.opacity(0.08), radius: 12, y: 3)
                .padding(.horizontal, 18)
                Spacer()
            }
        }
        .navigationTitle("Nouvel évènement")
    }
}

// Détail stylé admin
struct AdminEventDetailView: View {
    let event: Event
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 18) {
                Text(event.name)
                    .font(.title).bold().foregroundColor(.blue)
                Text(event.description)
                    .font(.body).foregroundColor(.gray)
                HStack {
                    Image(systemName: "mappin.and.ellipse").foregroundColor(.secondary)
                    Text(event.location).font(.subheadline)
                    Spacer()
                    Image(systemName: "person.3.fill").foregroundColor(.accentColor)
                    Text("\(event.participantsCount)/\(event.maxParticipants)").font(.subheadline)
                }
                Text("Statut: \(event.status)").font(.subheadline).foregroundColor(event.status == "open" ? .green : .red)
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Détail admin")
    }
}

