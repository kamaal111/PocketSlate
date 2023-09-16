//
//  UserDefaults.swift
//
//
//  Created by Kamaal M Farah on 11/06/2023.
//

import Foundation
import KamaalUtils
import PocketSlateAPI

extension UserDefaults {
    @UserDefaultsObject(key: "phrases")
    static var phrases: [UserDefaultsPhrase]?

    @UserDefaultsObject(key: "previously_selected_locales")
    static var previouslySelectedLocales: [Locale]?

    @UserDefaultsObject(key: "primary_locale")
    static var primaryLocale: Locale?

    @UserDefaultsObject(key: "secondary_locale")
    static var secondaryLocale: Locale?
}
