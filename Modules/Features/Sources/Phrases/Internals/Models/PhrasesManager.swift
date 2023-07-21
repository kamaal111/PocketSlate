//
//  PhrasesManager.swift
//
//
//  Created by Kamaal M Farah on 11/06/2023.
//

import CloudKit
import Foundation
import KamaalLogger
import CloudSyncing
import PocketSlateAPI
import KamaalExtensions

private let logger = KamaalLogger(from: PhrasesManager.self, failOnError: true)

public final class PhrasesManager: ObservableObject {
    @Published private(set) var phrases: [AppPhrase]
    @Published var isLoadingPhrase = false

    private var lastLocalePair: (primary: Locale, secondary: Locale)?
    private var pocketSlateAPI: PocketSlateAPI?
    private let notifications: [Notification.Name] = [
        .iCloudChanges,
    ]

    init() {
        self.phrases = []
        if let apiKey = SecretsJSON.shared.content?.apiKey {
            self.pocketSlateAPI = PocketSlateAPI(apiKey: apiKey)
        }

        setupObservers()
    }

    deinit {
        setupObservers()
    }

    enum Errors: Error {
        case creationFailure(context: Error)
        case fetchFailure(context: Error)
        case invalidPayload(context: Error)
        case deletionFailure(context: Error)
        case updateFailure(context: Error)
        case unknownTranslationFailure
        case translationFailure(context: PocketSlateAPIErrors)

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

    func translatePhrase(
        _ phrase: AppPhrase,
        from sourceLocale: Locale,
        to targetLocale: Locale
    ) async -> Result<Void, Errors> {
        await withLoading {
            guard let sourceText = phrase.translations[sourceLocale]?.first?.trimmingByWhitespacesAndNewLines,
                  !sourceText.isEmpty else {
                logger.error("Failed to get source text")
                return .failure(.unknownTranslationFailure)
            }

            guard let pocketSlateAPI else {
                assertionFailure("Pocket slate api should definitly be available at this point")
                return .failure(.unknownTranslationFailure)
            }

            let result = await pocketSlateAPI.translation
                .makeTranslation(forText: sourceText, from: sourceLocale, to: targetLocale)
            let translatedText: String
            switch result {
            case let .failure(failure):
                logger.error(label: "Failed to translate text", error: failure)
                return .failure(.translationFailure(context: failure))
            case let .success(success):
                translatedText = success
            }

            guard let index = phrases.findIndex(by: \.id, is: phrase.id) else {
                assertionFailure("Index should be present")
                return .failure(.unknownTranslationFailure)
            }

            var updatedPhrases = phrases
            updatedPhrases[index] = AppPhrase(
                id: phrase.id,
                creationDate: phrase.creationDate,
                updatedDate: Date(),
                translations: phrase.translations.merged(with: [targetLocale: [translatedText]]),
                source: phrase.source
            )
            logger.info("Translation found for \(sourceText)")

            return await updatePhrases(editedPhrases: updatedPhrases)
        }
    }

    func fetchPhrasesForLocalePair(primary: Locale, secondary: Locale) async -> Result<Void, Errors> {
        await withLoading {
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

            logger.info("Loaded phrases for locale pair of \(primary.identifier) and \(secondary.identifier)")
            await setPhrases(phrases)
            lastLocalePair = (primary, secondary)

            return .success(())
        }
    }

    func deleteTranslation(phrase: AppPhrase, primary: Locale, secondary: Locale) async -> Result<Void, Errors> {
        guard let index = phrases.findIndex(by: \.id, is: phrase.id) else {
            logger.error("No phrase found to delete")
            return .success(())
        }

        return await withLoading {
            let result = await phrase.deleteTranslations(for: [primary, secondary])
            switch result {
            case let .failure(failure):
                logger.error(label: "failed to delete translations", error: failure)
                return .failure(.fromAppPhrase(failure))
            case .success:
                break
            }

            logger.info("Deleted the phrase with id \(phrase.id)")
            await setPhrases(phrases.removed(at: index))

            return .success(())
        }
    }

    func updatePhrases(editedPhrases: [AppPhrase]) async -> Result<Void, Errors> {
        await withLoading {
            var updatedPhrases: [UUID: AppPhrase] = [:]
            var updateErrors: [AppPhrase.Errors] = []
            for phrase in editedPhrases {
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

            let listResult: Result<[AppPhrase], AppPhrase.Errors>
            if let lastLocalePair {
                listResult = await AppPhrase.listForLocalePair(
                    from: Constants.defaultSource,
                    primary: lastLocalePair.primary,
                    secondary: lastLocalePair.secondary
                )
            } else {
                logger.error("Should have had last locale pair here")
                listResult = await AppPhrase.list(from: Constants.defaultSource)
            }

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
    }

    func createPhrase(
        primaryTranslation: String,
        primaryLocale: Locale,
        secondaryTranslation: String,
        secondaryLocale: Locale
    ) async -> Result<Void, Errors> {
        await withLoading {
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
    }

    @MainActor
    private func setPhrases(_ phrases: [AppPhrase]) {
        self.phrases = phrases
            .sorted(by: \.updatedDate, using: .orderedDescending)
    }

    private func withLoading<T>(_ completion: () async -> T) async -> T {
        await setLoading(true)
        let result = await completion()
        await setLoading(false)
        return result
    }

    @MainActor
    private func setLoading(_ state: Bool) {
        guard isLoadingPhrase != state else { return }

        isLoadingPhrase = state
    }

    private func setupObservers() {
        for notification in notifications {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleNotification),
                name: notification,
                object: .none
            )
        }
    }

    private func removeObservers() {
        for notification in notifications {
            NotificationCenter.default.removeObserver(self, name: notification, object: .none)
        }
    }

    @objc
    private func handleNotification(_ notification: Notification) {
        switch notification.name {
        case .iCloudChanges:
            guard let lastLocalePair else {
                logger.error("Last locale pair should have been provided")
                return
            }

            let notificationObject = notification.object as? CKNotification
            logger.info("recieved iCloud changes notification; \(notificationObject as Any)")
            Task {
                await fetchPhrasesForLocalePair(primary: lastLocalePair.primary, secondary: lastLocalePair.secondary)
            }
        default:
            break
        }
    }
}
