//
//  AppPhrase.swift
//
//
//  Created by Kamaal M Farah on 17/09/2023.
//

import Models
import SwiftData
import Foundation

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
