//
//  UserEnvironmentModifier.swift
//
//
//  Created by Kamaal M Farah on 12/06/2023.
//

import SwiftUI

extension View {
    public func usersEnvironment() -> some View {
        modifier(UserEnvironmentModifier())
    }
}

private struct UserEnvironmentModifier: ViewModifier {
    @StateObject private var userData = UserData()

    func body(content: Content) -> some View {
        content
            .environmentObject(userData)
    }
}
