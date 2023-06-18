//
//  PhrasesManager.swift
//
//
//  Created by Kamaal M Farah on 11/06/2023.
//

import Foundation
import KamaalLogger
import KamaalExtensions

private let logger = KamaalLogger(from: PhrasesManager.self, failOnError: true)

public final class PhrasesManager: ObservableObject {
    @Published private(set) var phrases: [AppPhrase] = []

    enum Errors: Error {
        case creationFailure(context: Error)
    }

    @MainActor
    func fetchPhrasesForLocalePair(primary: Locale, secondary: Locale) {
        phrases = AppPhrase
            .listForLocalePair(primary: primary, secondary: secondary)
            .reversed()
    }

    @MainActor
    func deleteTranslation(phrase: AppPhrase, primary: Locale, secondary: Locale) {
        guard let index = phrases.findIndex(by: \.id, is: phrase.id) else {
            logger.error("No phrase foudn to delete")
            return
        }

        phrase.deleteTranslations(for: [primary, secondary])
        phrases = phrases
            .removed(at: index)
    }

    @MainActor
    func updatePhrases(editedPhrases: [AppPhrase]) {
        let editedPhrases = editedPhrases.map { $0.update(translations: $0.translations) }
        let groupedEditedPhrases = Dictionary(
            grouping: editedPhrases,
            by: \.id
        )
        phrases = AppPhrase
            .list()
            .map { groupedEditedPhrases[$0.id]?.first ?? $0 }
            .reversed()
    }

    @MainActor
    func createPhrase(
        primaryTranslation: String,
        primaryLocale: Locale,
        secondaryTranslation: String,
        secondaryLocale: Locale
    ) -> Result<Void, Errors> {
        let result = AppPhrase.create(translations: [
            primaryLocale: [primaryTranslation],
            secondaryLocale: [secondaryTranslation],
        ])
        let newPhrase: AppPhrase
        switch result {
        case let .failure(failure):
            logger.error(label: "failed to create phrase", error: failure)
            return .failure(.creationFailure(context: failure))
        case let .success(success):
            newPhrase = success
        }
        phrases = phrases.prepended(newPhrase)

        return .success(())
    }
}
