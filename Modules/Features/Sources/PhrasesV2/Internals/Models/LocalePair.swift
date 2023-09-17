//
//  LocalePair.swift
//
//
//  Created by Kamaal M Farah on 17/09/2023.
//

import Foundation

struct LocalePair: Equatable {
    let primary: Locale
    let secondary: Locale

    func swapped() -> LocalePair {
        LocalePair(primary: secondary, secondary: primary)
    }

    func setPrimary(with locale: Locale) -> LocalePair {
        LocalePair(primary: locale, secondary: secondary)
    }

    func setSecondary(with locale: Locale) -> LocalePair {
        LocalePair(primary: primary, secondary: locale)
    }
}
