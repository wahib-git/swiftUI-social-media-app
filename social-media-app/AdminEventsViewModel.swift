//
//  AdminEventsViewModel.swift
//  social-media-app
//
//  Created by mac 3 on 5/11/2025.
//

import Foundation

@MainActor
final class AdminEventsViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var loading = false
    @Published var error: String?

    private let service = EventService()

    func load() async {
        loading = true; defer { loading = false }
        do {
            events = try await service.listEvents(onlyOpen: false)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func create(event: Event) async {
        loading = true; defer { loading = false }
        do {
            try await service.createEvent(event)
            await load()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func delete(id: String) async {
        loading = true; defer { loading = false }
        do {
            try await service.deleteEvent(id: id)
            await load()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
