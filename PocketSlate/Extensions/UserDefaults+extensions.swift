//
//  UserDefaults+extensions.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 03/06/2023.
//

import Foundation
import KamaalUtils

extension UserDefaults {
    @UserDefaultsObject(key: "primary_locale")
    static var primaryLocale: Locale?

    @UserDefaultsObject(key: "secondary_locale")
    static var secondaryLocale: Locale?
}
