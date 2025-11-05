//
//  RootView.swift
//  social-media-app
//
//  Created by mac 3 on 5/11/2025.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var session: SessionViewModel
    var body: some View {
        Group {
            if let user = session.user {
                RoleGateView(user: user)
            } else {
                AuthView()
            }
        }
    }
}
