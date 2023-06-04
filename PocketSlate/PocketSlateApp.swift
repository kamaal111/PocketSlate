//
//  PocketSlateApp.swift
//  PocketSlate
//
//  Created by Kamaal Farah on 28/05/2023.
//

import SwiftUI

@main
struct PocketSlateApp: App {
    @StateObject private var userData = UserData()
    @StateObject private var phrasesManager = PhrasesManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 300, minHeight: 300)
                .environmentObject(userData)
                .environmentObject(phrasesManager)
        }
    }
}
