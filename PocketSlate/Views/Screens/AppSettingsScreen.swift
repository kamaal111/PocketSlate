//
//  AppSettingsScreen.swift
//  PocketSlate
//
//  Created by Kamaal Farah on 28/05/2023.
//

import Users
import SwiftUI
import KamaalSettings

struct AppSettingsScreen: View {
    @EnvironmentObject private var userData: UserData

    var body: some View {
        SettingsScreen(configuration: userData.settingsConfiguration)
    }
}

struct AppSettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        AppSettingsScreen()
    }
}
