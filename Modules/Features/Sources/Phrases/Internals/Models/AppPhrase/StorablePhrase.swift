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

    func update(translations: [Locale: [String]]) -> Result<Self, Errors>
    func deleteTranslations(for locales: [Locale]) -> Result<Void, Errors>

    static var source: PhraseStorageSources { get }

    static func list() -> Result<[Self], Errors>
    static func create(translations: [Locale: [String]]) -> Result<Self, Errors>
    static func listForLocale(_ locales: [Locale]) -> Result<[Self], Errors>
}

extension StorablePhrase {
    var translationsAreEmpty: Bool {
        translations.isEmpty || translations.values.allSatisfy(\.isEmpty)
    }
}
