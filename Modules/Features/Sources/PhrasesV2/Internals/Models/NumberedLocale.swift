//
//  NumberedLocale.swift
//
//
//  Created by Kamaal M Farah on 17/09/2023.
//

import Foundation

struct NumberedLocale: Hashable, Identifiable {
    let locale: Locale
    let number: Int

    var id: String { locale.identifier }

    func message(appLocale: Locale) -> String {
        "\(locale.identifier) - \(appLocale.localizedString(forIdentifier: locale.identifier)!)"
    }
}
