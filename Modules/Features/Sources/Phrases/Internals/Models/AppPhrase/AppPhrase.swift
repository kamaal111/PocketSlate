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
        case fetchFailure(context: Error)
        case creationFailure(context: Error)
        case deletionFailure(context: Error)
        case updateFailure(context: Error)
    }

    func update(translations: [Locale: [String]]) async -> Result<AppPhrase, Errors> {
        switch source {
        case .userDefaults:
            return await Self.mapErrors(
                UserDefaultsPhrase.fromAppPhrase(self).update(translations: translations),
                of: source
            )
            .map(\.asAppPhrase)
        case .cloud:
            return await Self.mapErrors(CloudPhrase.fromAppPhrase(self).update(translations: translations), of: source)
                .map(\.asAppPhrase)
        }
    }

    func deleteTranslations(for locales: [Locale]) async -> Result<AppPhrase?, Errors> {
        switch source {
        case .userDefaults:
            return await Self.mapErrors(UserDefaultsPhrase(
                id: id,
                kCreationDate: creationDate,
                updatedDate: updatedDate,
                translations: translations
            ).deleteTranslations(for: locales), of: source)
                .map { success in success?.asAppPhrase }
        case .cloud:
            return await Self.mapErrors(
                CloudPhrase(
                    id: id,
                    kCreationDate: creationDate,
                    updatedDate: updatedDate,
                    translations: translations
                )
                .deleteTranslations(for: locales),
                of: source
            )
            .map { success in success?.asAppPhrase }
        }
    }

    static func create(
        onSource source: PhraseStorageSources,
        translations: [Locale: [String]]
    ) async -> Result<AppPhrase, Errors> {
        switch source {
        case .userDefaults:
            return await Self.mapErrors(UserDefaultsPhrase.create(translations: translations), of: source)
                .map(\.asAppPhrase)
        case .cloud:
            return await Self.mapErrors(CloudPhrase.create(translations: translations), of: source)
                .map(\.asAppPhrase)
        }
    }

    static func list(from source: PhraseStorageSources) async -> Result<[AppPhrase], Errors> {
        switch source {
        case .userDefaults:
            return await Self.mapErrors(UserDefaultsPhrase.list(), of: source)
                .map { success in success.map(\.asAppPhrase) }
        case .cloud:
            return await Self.mapErrors(CloudPhrase.list(), of: source)
                .map { success in success.map(\.asAppPhrase) }
        }
    }

    static func listForLocalePair(
        from source: PhraseStorageSources,
        primary: Locale,
        secondary: Locale
    ) async -> Result<[AppPhrase], Errors> {
        let locales = [primary, secondary]
        switch source {
        case .userDefaults:
            return await Self.mapErrors(UserDefaultsPhrase.listForLocale(locales), of: source)
                .map { success in success.map(\.asAppPhrase) }
        case .cloud:
            return await Self.mapErrors(CloudPhrase.listForLocale(locales), of: source)
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
                    guard let error = error as? UserDefaultsPhrase.Errors else { fatalError("Failed to typecast") }
                    return UserDefaultsPhrase.internalErrorToAppPhraseError(error)
                case .cloud:
                    guard let error = error as? CloudPhrase.Errors else { fatalError("Failed to typecast") }
                    return CloudPhrase.internalErrorToAppPhraseError(error)
                }
            }
    }
}
