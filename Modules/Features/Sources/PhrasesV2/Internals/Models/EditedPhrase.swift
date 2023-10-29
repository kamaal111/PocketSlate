//
//  EditedPhrase.swift
//
//
//  Created by Kamaal M Farah on 29/10/2023.
//

import Models
import Foundation

struct EditedPhrase: Equatable, Identifiable {
    let id: UUID
    let translations: Pair<Translation>

    struct Translation: Equatable {
        let value: String
        let locale: Locale
    }
}
