//
//  RoleGateView.swift
//  social-media-app
//
//  Created by mac 3 on 5/11/2025.
//

import SwiftUI

struct RoleGateView: View {
    let user: AppUser
    var body: some View {
        if user.role == "admin" { AdminHomeView() } else { ParticipantHomeView() }
    }
}
