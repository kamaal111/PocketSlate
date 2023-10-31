//
//  PhrasesManager.swift
//
//
//  Created by Kamaal M Farah on 16/09/2023.
//

import Models
import SwiftData
import Algorithms
import Foundation
import Observation
import Persistance
import KamaalLogger
import PocketSlateAPI
import KamaalExtensions

private let logger = KamaalLogger(from: PhrasesManager.self, failOnError: true)

@Observable
final class PhrasesManager {
    private(set) var isLoadingPhrase = false
    private(set) var phrases: [AppPhrase] = []

    private var pocketSlateAPI: PocketSlateAPI?

    init() {
        if let secrets = SecretsJSON.shared.content, let apiKey = secrets.apiKey, let apiURL = secrets.apiURL {
            self.pocketSlateAPI = PocketSlateAPI(apiKey: apiKey, apiURL: apiURL)
        }
    }

    enum Errors: Error {
        case fetchFailure(context: Error)
        case unknownTranslationFailure
        case translationError(context: Error)
        case deleteTranslationsFailure(context: Error)
    }

    func createPhrase(values: Pair<String?>, locales: Pair<Locale>) async -> Result<Void, Errors> {
        await withLoading {
            guard let phrase = await AppPhrase.create(values: values, locales: locales) else {
                assertionFailure("No phrase created!")
                return .success(())
            }

            await setPhrases(phrases.prepended(phrase))
            return .success(())
        }
    }

    @MainActor
    func deleteTranslation(phrase: AppPhrase, locales: Pair<Locale>) async -> Result<Void, Errors> {
        await withLoading {
            let phraseIndex = phrases.findIndex(by: \.id, is: phrase.id)
            guard let phraseIndex else {
                logger.error("Failed to find phrase to remove")
                return .success(())
            }

            let phraseWithDeletedTranslations: AppPhrase?
            do {
                phraseWithDeletedTranslations = try phrase.deleteTranslations(for: locales.array)
            } catch {
                return .failure(.deleteTranslationsFailure(context: error))
            }

            if let phraseWithDeletedTranslations {
                let hasTranslationOfLocales = phraseWithDeletedTranslations.translations?.find(where: { translation in
                    guard let locale = translation.locale else { return false }
                    return locales.array.contains(locale)
                }) == nil
                if hasTranslationOfLocales {
                    setPhrases(phrases.removed(at: phraseIndex))
                } else {
                    var newPhrases = phrases
                    newPhrases[phraseIndex] = phraseWithDeletedTranslations
                    setPhrases(newPhrases)
                }
                return .success(())
            }

            setPhrases(phrases.removed(at: phraseIndex))
            return .success(())
        }
    }

    func updatePhrases(_ phrases: [(phrase: AppPhrase, changes: EditedPhrase)]) async -> Result<Void, Errors> {
        var lastError: Error?
        var updatedPhrases: [AppPhrase] = []
        for (phrase, changes) in phrases {
            var editedPhrase: AppPhrase?
            for updatedTranslation in changes.translations.array {
                do {
                    editedPhrase = try await (editedPhrase ?? phrase).editTranslation(
                        value: updatedTranslation.value.trimmingByWhitespacesAndNewLines,
                        locale: updatedTranslation.locale
                    )
                } catch {
                    lastError = error
                    continue
                }
            }
            assert(editedPhrase != nil)
            updatedPhrases = updatedPhrases.appended(editedPhrase!)
        }

        let currentAndUpdatedPhrases = self.phrases
            .enumerated()
            .map { _, phrase in updatedPhrases.find(by: \.id, is: phrase.id) ?? phrase }
        await setPhrases(currentAndUpdatedPhrases)

        if let lastError {
            return .failure(.translationError(context: lastError))
        }

        return .success(())
    }

    func translatePhrase(
        _ phrase: AppPhrase,
        from sourceLocale: Locale,
        to targetLocale: Locale
    ) async -> Result<Void, Errors> {
        await withLoading {
            guard let textToTranslate = phrase.translations?.find(by: \.locale, is: sourceLocale)?.value,
                  !textToTranslate.trimmingByWhitespacesAndNewLines.isEmpty else {
                return .failure(.unknownTranslationFailure)
            }

            guard let pocketSlateAPI else {
                logger.warning("Pocket slate api is not correctly configured")
                return .failure(.unknownTranslationFailure)
            }

            let result = await pocketSlateAPI.translation
                .makeTranslation(forText: textToTranslate, from: sourceLocale, to: targetLocale)
            let translatedText: String
            switch result {
            case let .failure(failure): return .failure(.translationError(context: failure))
            case let .success(success): translatedText = success
            }

            let updatedTranslation: AppPhrase
            do {
                updatedTranslation = try await phrase.editTranslation(value: translatedText, locale: targetLocale)
            } catch {
                return .failure(.translationError(context: error))
            }

            let phraseIndex = phrases.findIndex(by: \.id, is: updatedTranslation.id)!
            var newPhrases = phrases
            newPhrases[phraseIndex] = updatedTranslation
            await setPhrases(newPhrases)
            return .success(())
        }
    }

    func fetchPhrasesForLocalePair(_ locales: Pair<Locale>) async -> Result<Void, Errors> {
        await withLoading {
            let translations: [AppTranslation]
            do {
                translations = try await AppTranslation.fetchTranslations(forPair: locales)
            } catch {
                return .failure(.fetchFailure(context: error))
            }
            let phrases = translations
                .filter { translation in
                    guard let value = translation.value else { return false }
                    return !value.trimmingByWhitespacesAndNewLines.isEmpty
                }
                .compactMap(\.phrase)
                .uniqued(on: \.id)
            await setPhrases(phrases)
            return .success(())
        }
    }

    private func withLoading<T>(_ completion: () async -> T) async -> T {
        await setLoading(true)
        let result = await completion()
        await setLoading(false)
        return result
    }

    @MainActor
    private func setPhrases(_ phrases: [AppPhrase]) {
        self.phrases = phrases
            .filter { phrase in phrase.updatedDate != nil }
            .sorted(by: \.updatedDate!, using: .orderedDescending)
    }

    @MainActor
    private func setLoading(_ state: Bool) {
        guard isLoadingPhrase != state else { return }
        isLoadingPhrase = state
    }
}
