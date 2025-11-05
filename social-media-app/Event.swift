//
//  Event.swift
//  social-media-app
//
//  Created by mac 3 on 5/11/2025.
//

import Foundation
import FirebaseFirestore

struct Event: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var date: Date
    var startDate: Date
    var maxParticipants: Int
    var location: String
    var imageURL: String?
    var status: String // "open" | "closed"
    var participantsCount: Int
    var createdBy: String
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?
}

