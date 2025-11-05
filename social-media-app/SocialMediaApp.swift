//
//  CommunityEventsApp.swift
//  social-media-app
//
//  Created by mac 3 on 5/11/2025.
//

import SwiftUI
import FirebaseCore

@main
struct SocialMediaApp: App {
    @StateObject private var session = SessionViewModel()

    init() { FirebaseApp.configure() }

    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(session)
        }
    }
}
