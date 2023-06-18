//
//  AppPhrase.swift
//
//
//  Created by Kamaal M Farah on 11/06/2023.
//

import Foundation
import KamaalLogger
import KamaalExtensions

private let logger = KamaalLogger(from: AppPhrase.self, failOnError: true)

struct AppPhrase: Hashable, Codable, Identifiable {
    let id: UUID
    let translations: [Locale: [String]]

    enum Errors: Error {
        case invalidPayload
    }

    func update() -> AppPhrase {
        var allItems = Self.list()
        if let index = allItems.findIndex(by: \.id, is: id) {
            allItems[index] = AppPhrase(id: allItems[index].id, translations: translations)
        } else {
            allItems = allItems.appended(AppPhrase(id: UUID(), translations: translations))
            logger.error("There should have been a phrase stored in memory")
        }

        UserDefaults.phrases = allItems

        return self
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
