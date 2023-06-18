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
    private(set) var translations: [Locale: [String]]

    enum Errors: Error {
        case invalidPayload
    }

    var translationsAreEmpty: Bool {
        translations.isEmpty || translations.values.allSatisfy(\.isEmpty)
    }

    func update(translations: [Locale: [String]]) -> AppPhrase {
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

    func deleteTranslations(for locales: [Locale]) {
        var allItems = Self.list()
        guard let index = allItems.findIndex(by: \.id, is: id) else {
            logger.error("No phrase found to delete")
            return
        }

        var item = allItems[index]
        for locale in locales {
            item.translations[locale] = []
        }
        if item.translationsAreEmpty {
            UserDefaults.phrases = allItems
                .removed(at: index)
            return
        }

        allItems[index] = item
        UserDefaults.phrases = allItems
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
