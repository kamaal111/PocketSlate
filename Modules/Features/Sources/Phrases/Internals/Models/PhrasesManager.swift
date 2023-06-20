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
        let listResult = AppPhrase.listForLocalePair(primary: primary, secondary: secondary)
        let phrases: [AppPhrase]
        switch listResult {
        case let .failure(failure):
            logger.error(label: "failed to list locale pair", error: failure)
            return
        case let .success(success):
            phrases = success
        }
        self.phrases = phrases
    }

    @MainActor
    func deleteTranslation(phrase: AppPhrase, primary: Locale, secondary: Locale) {
        guard let index = phrases.findIndex(by: \.id, is: phrase.id) else {
            logger.error("No phrase found to delete")
            return
        }

        try? phrase.deleteTranslations(for: [primary, secondary]).get()
        phrases = phrases
            .removed(at: index)
    }

    @MainActor
    func updatePhrases(editedPhrases: [AppPhrase]) {
        let editedPhrases = editedPhrases.compactMap { try? $0.update(translations: $0.translations).get() }
        let groupedEditedPhrases = Dictionary(
            grouping: editedPhrases,
            by: \.id
        )
        let listResult = AppPhrase
            .list()
            .map {
                $0.map { groupedEditedPhrases[$0.id]?.first ?? $0 }
            }
        let phrases: [AppPhrase]
        switch listResult {
        case let .failure(failure):
            logger.error(label: "failed to list phrases", error: failure)
            return
        case let .success(success):
            phrases = success
        }
        self.phrases = phrases
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
