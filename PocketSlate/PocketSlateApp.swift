//
//  PocketSlateApp.swift
//  PocketSlate
//
//  Created by Kamaal Farah on 28/05/2023.
//

import Users
import SwiftUI
import Phrases

@main
struct PocketSlateApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 300, minHeight: 300)
                .usersEnvironment()
                .phrasesEnvironment()
        }
    }
}
