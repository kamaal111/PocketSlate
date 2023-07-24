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
    let creationDate: Date
    private(set) var updatedDate: Date
    private(set) var translations: [Locale: [String]]

    enum Errors: Error {
        case invalidPayload
    }

    enum CodingKeys: String, CodingKey {
        case id
        case creationDate = "kCreationDate"
        case updatedDate
        case translations
    }

    func deleteTranslations(for locales: [Locale]) async -> Result<Self?, Errors> {
        var allItems: [Self]
        switch await Self.list() {
        case let .failure(failure):
            return .failure(failure)
        case let .success(success):
            allItems = success
        }
        guard let index = allItems.findIndex(by: \.id, is: id) else {
            logger.error("No phrase found to delete")
            return .success(self)
        }

        var item = allItems[index]
        for locale in locales {
            item.translations[locale] = []
            item.updatedDate = Date()
        }
        if item.translationsAreEmpty {
            UserDefaults.phrases = allItems
                .removed(at: index)
            return .success(nil)
        }

        allItems[index] = item
        UserDefaults.phrases = allItems
        return .success(item)
    }

    func update(translations: [Locale: [String]]) async -> Result<Self, Errors> {
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
        var updatedPhrase: Self
        let now = Date()
        if let index = allItems.findIndex(by: \.id, is: id) {
            updatedPhrase = Self(
                id: allItems[index].id,
                creationDate: allItems[index].creationDate,
                updatedDate: now,
                translations: translations
            )
            updatedPhrase.updatedDate = Date()
            allItems[index] = updatedPhrase
        } else {
            updatedPhrase = Self(
                id: UUID(),
                creationDate: now,
                updatedDate: now,
                translations: translations
            )
            updatedPhrase.updatedDate = Date()
            allItems = allItems.appended(updatedPhrase)
            logger.error("There should have been a phrase stored in memory")
        }
        UserDefaults.phrases = allItems

        return .success(updatedPhrase)
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
            creationDate: now,
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

    static func listForLocale(_ locales: [Locale]) async -> Result<[Self], Errors> {
        await list()
            .map { success in
                success
                    .filter { phrase in
                        let translations = phrase.translations
                        guard !translations.isEmpty else { return false }

                        return !locales.allSatisfy { locale in translations[locale]?.isEmpty ?? true }
                    }
            }
    }

    static func internalErrorToAppPhraseError(_ error: Errors) -> AppPhrase.Errors {
        switch error {
        case .invalidPayload:
            return .invalidPayload
        }
    }

    static func fromAppPhrase(_ phrase: AppPhrase) -> UserDefaultsPhrase {
        UserDefaultsPhrase(
            id: phrase.id,
            creationDate: phrase.creationDate,
            updatedDate: phrase.updatedDate,
            translations: phrase.translations
        )
    }
}
