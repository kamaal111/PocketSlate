//
//  StorablePhrase.swift
//
//
//  Created by Kamaal M Farah on 20/06/2023.
//

import Foundation

enum PhraseStorageSources {
    case userDefaults
}

protocol StorablePhrase: Codable, Identifiable {
    associatedtype Errors: Error

    var id: UUID { get }
    var translations: [Locale: [String]] { get }
    var kCreationDate: Date { get }
    var updatedDate: Date { get }

    func deleteTranslations(for locales: [Locale]) -> Result<Void, Errors>

    static var source: PhraseStorageSources { get }

    static func list() -> Result<[Self], Errors>
    static func create(translations: [Locale: [String]]) -> Result<Self, Errors>
    static func listForLocale(_ locales: [Locale]) -> Result<[Self], Errors>
    static func update(_ id: UUID, translations: [Locale: [String]]) -> Result<Self, Errors>

    static func internalErrorToAppPhraseError(_ error: Errors) -> AppPhrase.Errors
}

extension StorablePhrase {
    var asAppPhrase: AppPhrase {
        AppPhrase(
            id: id,
            creationDate: kCreationDate,
            updatedDate: updatedDate,
            translations: translations,
            source: Self.source
        )
    }

    var translationsAreEmpty: Bool {
        translations.isEmpty || translations.values.allSatisfy(\.isEmpty)
    }
}
