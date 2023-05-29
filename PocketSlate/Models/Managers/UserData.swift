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
import KamaalExtensions

private let logger = KamaalLogger(from: UserData.self)

final class UserData: ObservableObject {
    @Published private var showLogs = true
    @Published private var appColor = AppColor(
        id: UUID(uuidString: "d3256bc6-84a4-4717-a970-9d2d3a1724b4")!,
        name: AppLocales.getText(.DEFAULT_COLOR),
        color: Color("AccentColor")
    )
    @Published private(set) var appLocale = Locale(identifier: "en")

    private static var currentLocale = Locale.current

    var settingsConfiguration: SettingsConfiguration {
        .init(
            feedback: .none,
            color: colorConfiguration,
            acknowledgements: AcknowledgementsJSON.shared.content,
            showLogs: showLogs
        )
    }

    static let locales: [Locale] = {
        let languages = Constants.priorityLanguages

        let groupedIdentifiers = Locale.availableIdentifiers
            .reduce((primary: [Locale](), sub: [Locale]())) { result, identifier in
                let locale = Locale(identifier: identifier)
                guard !languages.contains(locale) else { return result }

                let splittedIdentifer = identifier.split(separator: "_")
                if splittedIdentifer.count > 1 {
                    return (result.primary, result.sub.appended(locale))
                }

                return (result.primary.appended(locale), result.sub)
            }

        let combinedLocales = languages
            .concat(groupedIdentifiers.primary.sorted())
            .concat(groupedIdentifiers.sub.sorted())
            .uniques()

        guard let shortenedPreferredLocaleIdentifier = Locale.current.identifier.split(separator: "_").first
        else { return combinedLocales }

        let preferredLocale = Locale(identifier: String(shortenedPreferredLocaleIdentifier))
        guard let preferredLocaleIndex = combinedLocales.findIndex(by: \.identifier, is: preferredLocale.identifier)
        else { return combinedLocales }

        return combinedLocales
            .removed(at: preferredLocaleIndex)
            .prepended(preferredLocale)
    }()

    private var colorConfiguration: SettingsConfiguration.ColorsConfiguration {
        .init(colors: [appColor], currentColor: appColor)
    }
}
