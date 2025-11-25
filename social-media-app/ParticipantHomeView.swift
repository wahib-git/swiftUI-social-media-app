//
//  ParticipantHomeView.swift
//  social-media-app
//
//  Created by mac 3 on 5/11/2025.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ParticipantHomeView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var vm = ParticipantEventsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea() // fond doux sur toute la vue
                VStack(spacing: 18) {
                    HStack {
                        Image(systemName: "person.3.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        Spacer()
                        Button(action: { session.signOut() }) {
                            Label("Déconnexion", systemImage: "arrowshape.turn.up.left")
                                .labelStyle(.iconOnly)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Text("Événements à venir")
                        .font(.title).bold()
                        .foregroundColor(.accentColor)
                        .padding(.bottom, 6)

                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(vm.events) { e in
                                NavigationLink(destination: ParticipantEventDetailView(event: e)) {
                                    EventCard(event: e)
                                        .padding(.horizontal, 4)
                                }
                                .buttonStyle(.plain)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                        }
                        .padding(.bottom, 12)
                    }
                }
            }
            .task { await vm.load() }
            .navigationTitle("")
            .navigationBarHidden(true) // On remplace la barre par le header stylé
        }
    }
}

// Carte stylée pour chaque événement
struct EventCard: View {
    let event: Event
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.name)
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.bottom, 2)
            Text(event.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
                .padding(.bottom, 4)
            HStack {
                Label(event.location, systemImage: "mappin.and.ellipse")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Spacer()
                Label("\(event.participantsCount)/\(event.maxParticipants)", systemImage: "person.fill")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(14)
        .shadow(color: Color.blue.opacity(0.08), radius: 5, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(event.status == "open" ? Color.blue : Color.gray, lineWidth: 1)
        )
    }
}
