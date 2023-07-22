//
//  WideNavigationLink.swift
//  Playground
//
//  Created by Kamaal M Farah on 22/07/2023.
//

import SwiftUI
import KamaalUI

struct WideNavigationLink<Destination: Codable & Hashable, Content: View>: View {
    let destination: Destination
    let content: Content
    let onNavigate: (_ destination: Destination) -> Void

    init(destination: Destination, @ViewBuilder content: () -> Content) {
        self.destination = destination
        self.content = content()
        self.onNavigate = { _ in }
    }

    var body: some View {
        NavigationLink(value: destination) {
            view
        }
        .buttonStyle(.plain)
    }

    private var view: some View {
        content
            .foregroundColor(.accentColor)
        #if os(macOS)
            .kInvisibleFill()
        #endif
    }
}

#Preview {
    WideNavigationLink(destination: Screens.appLogoCreator) {
        Text("Content")
    }
}
