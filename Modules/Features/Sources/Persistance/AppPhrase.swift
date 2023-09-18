//
//  AppPhrase.swift
//
//
//  Created by Kamaal M Farah on 17/09/2023.
//

import Models
import SwiftData
import Foundation
import KamaalExtensions

@Model
public class AppPhrase: Hashable, Identifiable {
    public let id: UUID?

    @Relationship(deleteRule: .cascade, inverse: \AppTranslation.phrase)
    public private(set) var translations: [AppTranslation]?

    public let creationDate: Date?

    public let updatedDate: Date?

    public init(id: UUID, translations: [AppTranslation]?, creationDate: Date = Date(), updatedDate: Date = Date()) {
        self.id = id
        self.translations = translations
        self.creationDate = creationDate
        self.updatedDate = updatedDate
    }

    @MainActor
    public func editTranslation(value: String, locale: Locale) throws -> AppPhrase {
        var translationToBeEdited = translations?.find(by: \.locale, is: locale)
        guard translationToBeEdited?.value != value else { return self }

        let isNew = translationToBeEdited == nil
        if isNew {
            translationToBeEdited = try AppTranslation.create(
                locale: locale,
                value: value,
                phrase: self
            )
        } else {
            translationToBeEdited!.setValue(value)
        }

        var newTranslations = translations ?? []
        if !isNew {
            newTranslations = newTranslations.appended(translationToBeEdited!)
        } else {
            let existingTranslationIndex = newTranslations.findIndex(by: \.id, is: translationToBeEdited!.id!)!
            newTranslations = newTranslations
                .removed(at: existingTranslationIndex)
                .appended(translationToBeEdited!)
        }

        translations = newTranslations
        return self
    }

    @MainActor
    public static func create(values: Pair<String?>, locales: Pair<Locale>) -> AppPhrase? {
        let translations: [AppTranslation] = values.array
            .enumerated()
            .compactMap { index, value in
                guard let value else { return nil }

                let locale = locales.array[index]
                return AppTranslation(
                    id: UUID(),
                    locale: locale,
                    value: value,
                    phrase: nil
                )
            }
        assert(!translations.isEmpty)
        guard !translations.isEmpty else { return nil }

        let phrase = AppPhrase(id: UUID(), translations: translations)
        Persistance.shared.dataContainerContext.insert(phrase)

        return phrase
    }
}
