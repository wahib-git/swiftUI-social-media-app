//
//  Registration.swift
//  social-media-app
//
//  Created by mac 3 on 5/11/2025.
//

import Foundation
import FirebaseFirestore

struct Registration: Identifiable, Codable {
    @DocumentID var id: String?
    @ServerTimestamp var registeredAt: Date?
}

