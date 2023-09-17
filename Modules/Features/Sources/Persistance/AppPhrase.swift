//
//  AppPhrase.swift
//
//
//  Created by Kamaal M Farah on 17/09/2023.
//

import SwiftData
import Foundation

@Model
public class AppPhrase: Hashable, Identifiable {
    public let id: UUID?
    @Relationship(deleteRule: .cascade, inverse: \AppTranslation.phrase) public let translations: [AppTranslation]?
    public let creationDate: Date?
    public let updatedDate: Date?

    public init(id: UUID, translations: [AppTranslation]?, creationDate: Date, updatedDate: Date) {
        self.id = id
        self.translations = translations
        self.creationDate = creationDate
        self.updatedDate = updatedDate
    }
}
