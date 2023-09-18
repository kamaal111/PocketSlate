//
//  AppTranslation.swift
//
//
//  Created by Kamaal M Farah on 17/09/2023.
//

import Models
import SwiftData
import Foundation
import KamaalExtensions

@Model
public class AppTranslation: Hashable, Identifiable {
    public let id: UUID?
    public let localeIdentifier: String?
    public let value: String?
    public private(set) var phrase: AppPhrase?
    public let creationDate: Date?
    public let updatedDate: Date?

    public init(
        id: UUID,
        locale: Locale,
        value: String,
        phrase: AppPhrase?,
        creationDate: Date = Date(),
        updatedDate: Date = Date()
    ) {
        assert(!value.trimmingByWhitespacesAndNewLines.isEmpty)
        self.id = id
        self.localeIdentifier = locale.identifier
        self.value = value
        self.phrase = phrase
        self.creationDate = creationDate
        self.updatedDate = updatedDate
    }

    public var locale: Locale? {
        guard let localeIdentifier else {
            assertionFailure("Locale identifier should have been present")
            return nil
        }

        return Locale(identifier: localeIdentifier)
    }

    public func setPhrase(_ phrase: AppPhrase) {
        self.phrase = phrase
    }

    @MainActor
    public static func fetchTranslations(forPair locales: Pair<Locale>) throws -> [AppTranslation] {
        let primaryLocaleIdentifier = locales.primary.identifier
        let secondaryLocaleIdentifier = locales.secondary.identifier
        return try Persistance.shared.filter(predicate: #Predicate { translation in
            translation.localeIdentifier == primaryLocaleIdentifier
                || translation.localeIdentifier == secondaryLocaleIdentifier
        })
    }
}
