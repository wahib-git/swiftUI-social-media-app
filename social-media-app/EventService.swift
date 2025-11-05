import Foundation
import FirebaseFirestore

final class EventService {
    private let db = Firestore.firestore()

    func listEvents(onlyOpen: Bool) async throws -> [Event] {
        var query: Query = db.collection("events").order(by: "date")
        if onlyOpen {
            query = query.whereField("status", isEqualTo: "open")
        }
        let snap = try await query.getDocuments()
        return try snap.documents.compactMap { try $0.data(as: Event.self) }
    }

    func createEvent(_ e: Event) async throws {
        _ = try db.collection("events").addDocument(from: e)
    }

    func updateEvent(_ e: Event) async throws {
        guard let id = e.id else { return }
        try db.collection("events").document(id).setData(from: e, merge: true)
    }

    func deleteEvent(id: String) async throws {
        try await db.collection("events").document(id).delete()
    }
    // Inscription atomique via transaction
    func register(userId: String, eventId: String) async throws {
      let eventRef = db.collection("events").document(eventId)
      let regRef = eventRef.collection("registrations").document(userId)

    }
  
    func unregister(userId: String, eventId: String) async throws {
      let eventRef = db.collection("events").document(eventId)
      let regRef = eventRef.collection("registrations").document(userId)
   

  }
}
