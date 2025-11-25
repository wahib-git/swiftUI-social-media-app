import Foundation
import FirebaseFirestore

final class EventService {
    private let db = Firestore.firestore()

    func listEvents(onlyOpen: Bool) async throws -> [Event] {
        var query: Query = db.collection("events").order(by: "date")
        if onlyOpen { query = query.whereField("status", isEqualTo: "open") }
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

    // Inscription simple: création du doc + incrément atomique séparé (sans transaction)
    func register(userId: String, eventId: String) async throws {
        let eventRef = db.collection("events").document(eventId)
        let regRef = eventRef.collection("registrations").document(userId)

        // 1) Créer l'inscription si elle n'existe pas (idempotence basique côté client)
        let regSnap = try await regRef.getDocument()
        if !regSnap.exists {
            try await regRef.setData(["registeredAt": FieldValue.serverTimestamp()])
        }

        // 2) Incrémenter le compteur de participants
        try await eventRef.updateData([
            "participantsCount": FieldValue.increment(Int64(1)),
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }

    // Désinscription simple: suppression du doc + décrément atomique séparé (sans transaction)
    func unregister(userId: String, eventId: String) async throws {
        let eventRef = db.collection("events").document(eventId)
        let regRef = eventRef.collection("registrations").document(userId)

        // 1) Supprimer l'inscription si elle existe
        let regSnap = try await regRef.getDocument()
        if regSnap.exists {
            try await regRef.delete()
        }

        // 2) Décrémenter le compteur
        try await eventRef.updateData([
            "participantsCount": FieldValue.increment(Int64(-1)),
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }
}
