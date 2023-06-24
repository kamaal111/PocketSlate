//
//  UserDefaultsPhrase.swift
//
//
//  Created by Kamaal M Farah on 20/06/2023.
//

import Foundation
import KamaalLogger
import KamaalExtensions

private let logger = KamaalLogger(from: UserDefaultsPhrase.self, failOnError: true)

struct UserDefaultsPhrase: Codable, StorablePhrase {
    let id: UUID
    let kCreationDate: Date
    let updatedDate: Date
    private(set) var translations: [Locale: [String]]

    enum Errors: Error {
        case invalidPayload
    }

    func deleteTranslations(for locales: [Locale]) async -> Result<Void, Errors> {
        var allItems: [Self]
        switch await Self.list() {
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

    static func list() async -> Result<[Self], Errors> {
        .success(UserDefaults.phrases?.reversed() ?? [])
    }

    static func create(translations: [Locale: [String]]) async -> Result<Self, Errors> {
        if translations.isEmpty || translations.values.allSatisfy(\.isEmpty) {
            return .failure(.invalidPayload)
        }

        let now = Date()
        let newPhrase = Self(
            id: UUID(),
            kCreationDate: now,
            updatedDate: now,
            translations: translations
        )
        let listResult = await list().map { $0.appended(newPhrase) }
        switch listResult {
        case let .failure(failure):
            return .failure(failure)
        case let .success(success):
            UserDefaults.phrases = success
        }
        return .success(newPhrase)
    }

    static func update(_ id: UUID, translations: [Locale: [String]]) async -> Result<Self, Errors> {
        if translations.isEmpty || translations.values.allSatisfy(\.isEmpty) {
            return .failure(.invalidPayload)
        }

        var allItems: [Self]
        switch await Self.list() {
        case let .failure(failure):
            return .failure(failure)
        case let .success(success):
            allItems = success
        }
        let updatedPhrase: Self
        let now = Date()
        if let index = allItems.findIndex(by: \.id, is: id) {
            updatedPhrase = Self(
                id: allItems[index].id,
                kCreationDate: allItems[index].kCreationDate,
                updatedDate: now,
                translations: translations
            )
            allItems[index] = updatedPhrase
        } else {
            updatedPhrase = Self(
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

    static func listForLocale(_ locales: [Locale]) async -> Result<[Self], Errors> {
        await list()
            .map {
                $0
                    .filter {
                        let translations = $0.translations
                        guard !translations.isEmpty else { return false }

                        return !locales.allSatisfy { translations[$0]?.isEmpty ?? true }
                    }
            }
    }

    static func internalErrorToAppPhraseError(_ error: Errors) -> AppPhrase.Errors {
        switch error {
        case .invalidPayload:
            return .invalidPayload
        }
    }
}
