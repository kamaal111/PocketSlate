//
//  AppPhrase.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 04/06/2023.
//

import Foundation
import KamaalExtensions

struct AppPhrase: Hashable, Codable, Identifiable {
    let id: UUID
    let translations: [Locale: [String]]

    enum Errors: Error {
        case invalidPayload
    }

    static func create(translations: [Locale: [String]]) -> Result<AppPhrase, Errors> {
        if translations.isEmpty || translations.values.allSatisfy(\.isEmpty) {
            return .failure(.invalidPayload)
        }

        let newPhrase = AppPhrase(id: UUID(), translations: translations)
        UserDefaults.phrases = list().appended(newPhrase)
        return .success(newPhrase)
    }

    static func list() -> [AppPhrase] {
        UserDefaults.phrases ?? []
    }

    static func listForLocalePair(primary: Locale, secondary: Locale) -> [AppPhrase] {
        list()
            .filter {
                let translations = $0.translations
                return !translations.isEmpty &&
                    !(translations[primary]?.isEmpty ?? true ||
                        translations[secondary]?.isEmpty ?? true)
            }
    }
}
