//
//  InternalUserDefaultsPhrase.swift
//
//
//  Created by Kamaal M Farah on 20/06/2023.
//

import Foundation
import KamaalLogger
import KamaalExtensions

private let logger = KamaalLogger(from: InternalUserDefaultsPhrase.self, failOnError: true)

struct InternalUserDefaultsPhrase: Codable, Identifiable, StorablePhrase {
    let id: UUID
    let kCreationDate: Date
    let updatedDate: Date
    private(set) var translations: [Locale: [String]]

    enum Errors: Error {
        case invalidPayload
    }

    func update(translations: [Locale: [String]]) -> Result<InternalUserDefaultsPhrase, Errors> {
        if translations.isEmpty || translations.values.allSatisfy(\.isEmpty) {
            return .failure(.invalidPayload)
        }

        let listResult = Self.list()
        var allItems: [InternalUserDefaultsPhrase]
        switch listResult {
        case let .failure(failure):
            return .failure(failure)
        case let .success(success):
            allItems = success
        }
        let updatedPhrase: InternalUserDefaultsPhrase
        let now = Date()
        if let index = allItems.findIndex(by: \.id, is: id) {
            updatedPhrase = InternalUserDefaultsPhrase(
                id: allItems[index].id,
                kCreationDate: allItems[index].kCreationDate,
                updatedDate: now,
                translations: translations
            )
            allItems[index] = updatedPhrase
        } else {
            updatedPhrase = InternalUserDefaultsPhrase(
                id: UUID(),
                kCreationDate: now,
                updatedDate: now,
                translations: translations
            )
            allItems = allItems.appended(updatedPhrase)
            logger.error("There should have been a phrase stored in memory")
        }
        UserDefaults.phrases = allItems

        return .success(updatedPhrase)
    }

    func deleteTranslations(for locales: [Locale]) -> Result<Void, Errors> {
        let listResult = Self.list()
        var allItems: [InternalUserDefaultsPhrase]
        switch listResult {
        case let .failure(failure):
            return .failure(failure)
        case let .success(success):
            allItems = success
        }
        guard let index = allItems.findIndex(by: \.id, is: id) else {
            logger.error("No phrase found to delete")
            return .success(())
        }

        var item = allItems[index]
        for locale in locales {
            item.translations[locale] = []
        }
        if item.translationsAreEmpty {
            UserDefaults.phrases = allItems
                .removed(at: index)
            return .success(())
        }

        allItems[index] = item
        UserDefaults.phrases = allItems
        return .success(())
    }

    static let source: PhraseStorageSources = .userDefaults

    static func list() -> Result<[InternalUserDefaultsPhrase], Errors> {
        .success(UserDefaults.phrases?.reversed() ?? [])
    }

    static func create(translations: [Locale: [String]]) -> Result<InternalUserDefaultsPhrase, Errors> {
        if translations.isEmpty || translations.values.allSatisfy(\.isEmpty) {
            return .failure(.invalidPayload)
        }

        let now = Date()
        let newPhrase = InternalUserDefaultsPhrase(
            id: UUID(),
            kCreationDate: now,
            updatedDate: now,
            translations: translations
        )
        let listResult = list().map { $0.appended(newPhrase) }
        switch listResult {
        case let .failure(failure):
            return .failure(failure)
        case let .success(success):
            UserDefaults.phrases = success
        }
        return .success(newPhrase)
    }

    static func listForLocale(_ locales: [Locale]) -> Result<[InternalUserDefaultsPhrase], Errors> {
        list()
            .map {
                $0
                    .filter {
                        let translations = $0.translations
                        guard !translations.isEmpty else { return false }

                        return !locales.allSatisfy { translations[$0]?.isEmpty ?? true }
                    }
            }
    }
}
