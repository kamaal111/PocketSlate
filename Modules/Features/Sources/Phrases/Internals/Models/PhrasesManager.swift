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
        case fetchFailure(context: Error)
        case invalidPayload(context: Error)

        static func fromAppPhrase(_ error: AppPhrase.Errors) -> Errors {
            switch error {
            case .invalidPayload:
                return .invalidPayload(context: error)
            }
        }
    }

    @MainActor
    func fetchPhrasesForLocalePair(primary: Locale, secondary: Locale) -> Result<Void, Errors> {
        let listResult = AppPhrase.listForLocalePair(
            from: Constants.defaultSource,
            primary: primary,
            secondary: secondary
        )
        let phrases: [AppPhrase]
        switch listResult {
        case let .failure(failure):
            logger.error(label: "failed to list locale pair", error: failure)
            return .failure(.fetchFailure(context: failure))
        case let .success(success):
            phrases = success
        }
        self.phrases = phrases
        return .success(())
    }

    @MainActor
    func deleteTranslation(phrase: AppPhrase, primary: Locale, secondary: Locale) -> Result<Void, Errors> {
        guard let index = phrases.findIndex(by: \.id, is: phrase.id) else {
            logger.error("No phrase found to delete")
            return .success(())
        }

        let result = phrase.deleteTranslations(for: [primary, secondary])
        switch result {
        case let .failure(failure):
            logger.error(label: "failed to delete translations", error: failure)
            return .failure(.fromAppPhrase(failure))
        case .success:
            break
        }

        phrases = phrases
            .removed(at: index)
        return .success(())
    }

    @MainActor
    func updatePhrases(editedPhrases: [AppPhrase]) -> Result<Void, Errors> {
        var updatedPhrases: [UUID: AppPhrase] = [:]
        var updateErrors: [AppPhrase.Errors] = []
        for phrase in editedPhrases {
            let result = phrase.update(translations: phrase.translations)
            switch result {
            case let .failure(failure):
                logger.error(label: "failed to update a phrase", error: failure)
                updateErrors = updateErrors.appended(failure)
            case let .success(success):
                updatedPhrases[success.id] = success
            }
        }
        guard updateErrors.isEmpty else { return .failure(.fromAppPhrase(updateErrors[0])) }

        let listResult = AppPhrase.list(from: Constants.defaultSource)
        let phrases: [AppPhrase]
        switch listResult {
        case let .failure(failure):
            logger.error(label: "failed to list phrases", error: failure)
            return .failure(.fromAppPhrase(failure))
        case let .success(success):
            phrases = success
        }
        self.phrases = phrases
            .map { updatedPhrases[$0.id] ?? $0 }

        return .success(())
    }

    @MainActor
    func createPhrase(
        primaryTranslation: String,
        primaryLocale: Locale,
        secondaryTranslation: String,
        secondaryLocale: Locale
    ) -> Result<Void, Errors> {
        let result = AppPhrase.create(
            onSource: Constants.defaultSource,
            translations: [
                primaryLocale: [primaryTranslation],
                secondaryLocale: [secondaryTranslation],
            ]
        )
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
