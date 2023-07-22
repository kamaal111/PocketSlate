//
//  ContentView.swift
//  Playground
//
//  Created by Kamaal M Farah on 22/07/2023.
//

import AppUI
import SwiftUI
import KamaalUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            KScrollableForm {
                KSection(header: "Personalization") {
                    PlaygroundNavigationButton(title: "App logo creator", destination: .appLogoCreator)
                }
            }
            .navigationDestination(for: Screens.self) { screen in
                switch screen {
                case .appLogoCreator: AppLogoCreatorScreen()
                }
            }
        }
        #if os(macOS)
        .padding(.all, .medium)
        #endif
    }
}

#Preview {
    ContentView()
}
