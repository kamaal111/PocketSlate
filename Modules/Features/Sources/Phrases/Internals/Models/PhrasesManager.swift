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
    @Published private(set) var phrases: [AppPhrase]

    init() {
        self.phrases = []
    }

    enum Errors: Error {
        case creationFailure(context: Error)
        case fetchFailure(context: Error)
        case invalidPayload(context: Error)
        case deletionFailure(context: Error)
        case updateFailure(context: Error)

        static func fromAppPhrase(_ error: AppPhrase.Errors) -> Errors {
            switch error {
            case .invalidPayload:
                return .invalidPayload(context: error)
            case .fetchFailure:
                return .fetchFailure(context: error)
            case .creationFailure:
                return .creationFailure(context: error)
            case .deletionFailure:
                return .deletionFailure(context: error)
            case .updateFailure:
                return .updateFailure(context: error)
            }
        }
    }

    func fetchPhrasesForLocalePair(primary: Locale, secondary: Locale) async -> Result<Void, Errors> {
        let listResult = await AppPhrase.listForLocalePair(
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
        await setPhrases(phrases)

        return .success(())
    }

    func deleteTranslation(phrase: AppPhrase, primary: Locale, secondary: Locale) async -> Result<Void, Errors> {
        guard let index = phrases.findIndex(by: \.id, is: phrase.id) else {
            logger.error("No phrase found to delete")
            return .success(())
        }

        let result = await phrase.deleteTranslations(for: [primary, secondary])
        switch result {
        case let .failure(failure):
            logger.error(label: "failed to delete translations", error: failure)
            return .failure(.fromAppPhrase(failure))
        case .success:
            break
        }
        await setPhrases(phrases.removed(at: index))

        return .success(())
    }

    func updatePhrases(editedPhrases: [AppPhrase]) async -> Result<Void, Errors> {
        var updatedPhrases: [UUID: AppPhrase] = [:]
        var updateErrors: [AppPhrase.Errors] = []
        for phrase in editedPhrases {
            #warning("Handle these comments")
            // How do I do this asyncronous?
            // Maybe even better just a batch update
            let result = await phrase.update(translations: phrase.translations)
            switch result {
            case let .failure(failure):
                logger.error(label: "failed to update a phrase", error: failure)
                updateErrors = updateErrors.appended(failure)
            case let .success(success):
                updatedPhrases[success.id] = success
            }
        }
        guard updateErrors.isEmpty else { return .failure(.fromAppPhrase(updateErrors[0])) }

        let listResult = await AppPhrase.list(from: Constants.defaultSource)
        let phrases: [AppPhrase]
        switch listResult {
        case let .failure(failure):
            logger.error(label: "failed to list phrases", error: failure)
            return .failure(.fromAppPhrase(failure))
        case let .success(success):
            phrases = success
        }
        await setPhrases(phrases.map { updatedPhrases[$0.id] ?? $0 })

        return .success(())
    }

    func createPhrase(
        primaryTranslation: String,
        primaryLocale: Locale,
        secondaryTranslation: String,
        secondaryLocale: Locale
    ) async -> Result<Void, Errors> {
        let result = await AppPhrase.create(
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
        await setPhrases(phrases.prepended(newPhrase))

        return .success(())
    }

    @MainActor
    private func setPhrases(_ phrases: [AppPhrase]) {
        self.phrases = phrases
    }
}
