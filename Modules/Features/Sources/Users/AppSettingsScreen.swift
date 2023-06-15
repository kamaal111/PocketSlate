//
//  AppSettingsScreen.swift
//  PocketSlate
//
//  Created by Kamaal Farah on 28/05/2023.
//

import SwiftUI
import KamaalSettings

public struct AppSettingsScreen: View {
    @EnvironmentObject private var userData: UserData

    public init() { }

    public var body: some View {
        SettingsScreen(configuration: userData.settingsConfiguration)
    }
}

struct AppSettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        AppSettingsScreen()
    }
}
