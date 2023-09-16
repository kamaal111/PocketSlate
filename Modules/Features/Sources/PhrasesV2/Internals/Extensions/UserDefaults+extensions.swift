//
//  UserDefaults+extensions.swift
//
//
//  Created by Kamaal M Farah on 16/09/2023.
//

import Foundation
import KamaalUtils

extension UserDefaults {
    @UserDefaultsObject(key: "previously_selected_locales")
    static var previouslySelectedLocales: [Locale]?

    @UserDefaultsObject(key: "primary_locale")
    static var primaryLocale: Locale?

    @UserDefaultsObject(key: "secondary_locale")
    static var secondaryLocale: Locale?
}
