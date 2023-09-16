//
//  PocketSlateApp.swift
//  PocketSlate
//
//  Created by Kamaal Farah on 28/05/2023.
//

import Users
import SwiftUI
import PhrasesV2

@main
struct PocketSlateApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    #else
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 300, minHeight: 300)
                .usersEnvironment()
                .phrasesEnvironment()
        }
    }
}
