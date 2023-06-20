//
//  AppPhrase.swift
//
//
//  Created by Kamaal M Farah on 11/06/2023.
//

import Foundation

struct AppPhrase: Hashable, Identifiable {
    let id: UUID
    let creationDate: Date
    let updatedDate: Date
    let translations: [Locale: [String]]
    let source: PhraseStorageSources

    enum Errors: Error {
        case invalidPayload

        static func fromUserDefaults(_ error: InternalUserDefaultsPhrase.Errors) -> Errors {
            switch error {
            case .invalidPayload:
                return .invalidPayload
            }
        }
    }

    func update(translations: [Locale: [String]]) -> Result<AppPhrase, Errors> {
        InternalUserDefaultsPhrase(
            id: id,
            kCreationDate: creationDate,
            updatedDate: updatedDate,
            translations: self.translations
        )
        .update(translations: translations)
        .mapError { Errors.fromUserDefaults($0) }
        .map { AppPhrase.fromUserDefaults($0) }
    }

    func deleteTranslations(for locales: [Locale]) -> Result<Void, Errors> {
        InternalUserDefaultsPhrase(
            id: id,
            kCreationDate: creationDate,
            updatedDate: updatedDate,
            translations: translations
        )
        .deleteTranslations(for: locales)
        .mapError { Errors.fromUserDefaults($0) }
    }

    static func create(translations: [Locale: [String]]) -> Result<AppPhrase, Errors> {
        InternalUserDefaultsPhrase
            .create(translations: translations)
            .mapError { Errors.fromUserDefaults($0) }
            .map { AppPhrase.fromUserDefaults($0) }
    }

    static func list() -> Result<[AppPhrase], Errors> {
        InternalUserDefaultsPhrase
            .list()
            .mapError { Errors.fromUserDefaults($0) }
            .map { $0.map { AppPhrase.fromUserDefaults($0) } }
    }

    static func listForLocalePair(primary: Locale, secondary: Locale) -> Result<[AppPhrase], Errors> {
        InternalUserDefaultsPhrase
            .listForLocale([primary, secondary])
            .mapError { Errors.fromUserDefaults($0) }
            .map { $0.map { AppPhrase.fromUserDefaults($0) } }
    }

    static func fromUserDefaults(_ phrase: InternalUserDefaultsPhrase) -> AppPhrase {
        AppPhrase(
            id: phrase.id,
            creationDate: phrase.kCreationDate,
            updatedDate: phrase.updatedDate,
            translations: phrase.translations,
            source: .userDefaults
        )
    }
}
