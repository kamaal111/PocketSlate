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
    }

    func update(translations: [Locale: [String]]) -> Result<AppPhrase, Errors> {
        switch source {
        case .userDefaults:
            return Self.mapErrors(UserDefaultsPhrase.update(id, translations: translations), of: source)
                .map(\.asAppPhrase)
        }
    }

    func deleteTranslations(for locales: [Locale]) -> Result<Void, Errors> {
        switch source {
        case .userDefaults:
            return Self.mapErrors(UserDefaultsPhrase(
                id: id,
                kCreationDate: creationDate,
                updatedDate: updatedDate,
                translations: translations
            ).deleteTranslations(for: locales), of: source)
        }
    }

    static func create(
        onSource source: PhraseStorageSources,
        translations: [Locale: [String]]
    ) -> Result<AppPhrase, Errors> {
        switch source {
        case .userDefaults:
            return Self.mapErrors(UserDefaultsPhrase.create(translations: translations), of: source)
                .map(\.asAppPhrase)
        }
    }

    static func list(from source: PhraseStorageSources) -> Result<[AppPhrase], Errors> {
        switch source {
        case .userDefaults:
            return Self.mapErrors(UserDefaultsPhrase.list(), of: source)
                .map { success in success.map(\.asAppPhrase) }
        }
    }

    static func listForLocalePair(
        from source: PhraseStorageSources,
        primary: Locale,
        secondary: Locale
    ) -> Result<[AppPhrase], Errors> {
        switch source {
        case .userDefaults:
            return Self.mapErrors(UserDefaultsPhrase.listForLocale([primary, secondary]), of: source)
                .map { success in success.map(\.asAppPhrase) }
        }
    }

    private static func fromStorablePhrase(_ phrase: some StorablePhrase) -> AppPhrase {
        AppPhrase(
            id: phrase.id,
            creationDate: phrase.kCreationDate,
            updatedDate: phrase.updatedDate,
            translations: phrase.translations,
            source: .userDefaults
        )
    }

    private static func mapErrors<T>(
        _ result: Result<T, some Error>,
        of source: PhraseStorageSources
    ) -> Result<T, Errors> {
        result
            .mapError { error in
                switch source {
                case .userDefaults:
                    switch error as? UserDefaultsPhrase.Errors {
                    case .invalidPayload:
                        return .invalidPayload
                    case .none:
                        assertionFailure("Should have handled all errors")
                        return .invalidPayload
                    }
                }
            }
    }
}
