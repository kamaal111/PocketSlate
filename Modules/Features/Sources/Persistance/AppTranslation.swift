//
//  AppTranslation.swift
//
//
//  Created by Kamaal M Farah on 17/09/2023.
//

import SwiftData
import Foundation
import KamaalExtensions

@Model
public class AppTranslation: Hashable, Identifiable {
    public let id: UUID?
    public let localeIdentifier: String?
    public let value: String?
    public let phrase: AppPhrase?
    public let creationDate: Date?
    public let updatedDate: Date?

    public init(id: UUID, locale: Locale, value: String, phrase: AppPhrase?, creationDate: Date, updatedDate: Date) {
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
}
