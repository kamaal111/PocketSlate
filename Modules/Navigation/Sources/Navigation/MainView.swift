//
//  MainView.swift
//  PocketSlate
//
//  Created by Kamaal Farah on 28/05/2023.
//

import Users
import SwiftUI
import KamaalUI
import PhrasesV1
import KamaalPopUp
import KamaalSettings
import KamaalNavigation

struct MainView: View {
    @StateObject private var popperUpManager = KPopUpManager(config: .init())

    let screen: Screens
    let displayMode: DisplayMode

    init(screen: Screens, displayMode: DisplayMode? = nil) {
        self.screen = screen
        self.displayMode = displayMode ?? (screen.isSidebarItem && screen.isTabItem ? .large : .inline)
    }

    var body: some View {
        KJustStack {
            switch screen {
            case .phrases:
                PhrasesScreen()
            case .settings:
                AppSettingsScreen()
            }
        }
        .ktakeSizeEagerly()
        .navigationTitle(title: screen.title, displayMode: displayMode)
        .withKPopUp(popperUpManager)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(screen: .phrases)
    }
}
