//
//  ParticipantEventsViewModel.swift
//  social-media-app
//
//  Created by mac 3 on 5/11/2025.
//

import Foundation

@MainActor
final class ParticipantEventsViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var loading = false
    @Published var error: String?

    private let service = EventService()

    func load() async {
      loading = true; defer { loading = false }
      do {
        events = try await service.listEvents(onlyOpen: true)
      } catch {
        self.error = error.localizedDescription
      }
    }


    func register(uid: String, eventId: String) async {
      loading = true; defer { loading = false }
      do {
        try await service.register(userId: uid, eventId: eventId)
        await load()
      } catch {
        self.error = error.localizedDescription
      }
    }


    func unregister(uid: String, eventId: String) async {
        loading = true; defer { loading = false }
        do {
          try await service.unregister(userId: uid, eventId: eventId)
          await load()
        } catch {
            self.error = error.localizedDescription }
    }
}
