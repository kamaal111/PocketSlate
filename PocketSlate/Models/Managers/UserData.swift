//
//  UserData.swift
//  PocketSlate
//
//  Created by Kamaal Farah on 28/05/2023.
//

import SwiftUI
import AppLocales
import KamaalLogger
import KamaalSettings

private let logger = KamaalLogger(from: UserData.self)

final class UserData: ObservableObject {
    @Published private var showLogs = true
    @Published private var appColor = AppColor(
        id: UUID(uuidString: "d3256bc6-84a4-4717-a970-9d2d3a1724b4")!,
        name: AppLocales.getText(.DEFAULT_COLOR),
        color: Color("AccentColor")
    )

    private static var currentLocale = Locale.current

    var settingsConfiguration: SettingsConfiguration {
        .init(
            feedback: .none,
            color: colorConfiguration,
            acknowledgements: AcknowledgementsJSON.shared.content,
            showLogs: showLogs
        )
    }

    static var languageCode: String {
        let identifier: String?
        if #available(macOS 13, iOS 16, *) {
            assert(currentLocale.language.languageCode?.identifier != nil)
            identifier = currentLocale.language.languageCode?.identifier
        } else {
            identifier = currentLocale.languageCode
        }

        assert(identifier != nil)
        return identifier ?? Constants.defaultLanguageCode
    }

    private var colorConfiguration: SettingsConfiguration.ColorsConfiguration {
        .init(colors: [appColor], currentColor: appColor)
    }
}
