//
//  PhrasesManager.swift
//
//
//  Created by Kamaal M Farah on 16/09/2023.
//

import SwiftData
import Algorithms
import Foundation
import Observation
import Persistance

@Observable
final class PhrasesManager {
    private(set) var isLoadingPhrase = false
    private(set) var phrases: [AppPhrase] = []

    enum Errors: Error {
        case fetchFailure(context: Error)
    }

    func fetchPhrasesForLocalePair(_ locales: LocalePair) async -> Result<Void, Errors> {
        await withLoading {
            let translationsResult = await fetchTranslations(forPair: locales)
            let translations: [AppTranslation]
            switch translationsResult {
            case let .failure(failure): return .failure(failure)
            case let .success(successs): translations = successs
            }
            let phrases = translations.compactMap(\.phrase).uniqued(on: \.id)
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
    }

    @MainActor
    private func fetchTranslations(forPair locales: LocalePair) -> Result<[AppTranslation], Errors> {
        let primaryLocaleIdentifier = locales.primary.identifier
        let secondaryLocaleIdentifier = locales.secondary.identifier
        var translationFetch = FetchDescriptor<AppTranslation>(
            predicate: #Predicate { translation in
                translation.localeIdentifier == primaryLocaleIdentifier
                    || translation.localeIdentifier == secondaryLocaleIdentifier
            }
        )
        translationFetch.includePendingChanges = true

        let translations: [AppTranslation]
        do {
            translations = try Persistance.shared.dataContainer.mainContext.fetch(translationFetch)
        } catch {
            return .failure(.fetchFailure(context: error))
        }

        return .success(translations)
    }

    @MainActor
    private func setLoading(_ state: Bool) {
        guard isLoadingPhrase != state else { return }

        isLoadingPhrase = state
    }
}
