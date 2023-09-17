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
import KamaalExtensions

@Observable
final class PhrasesManager {
    private(set) var isLoadingPhrase = false
    private(set) var phrases: [AppPhrase] = []

    enum Errors: Error {
        case fetchFailure(context: Error)
    }

    func createPhrase(values: Pair<String?>, locales: Pair<Locale>) async -> Result<Void, Errors> {
        await withLoading {
            guard let phrase = await AppPhrase.create(values: values, locales: locales) else {
                assertionFailure("No phrase created!")
                return .success(())
            }

            await setPhrases(phrases.appended(phrase))
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
    private func setLoading(_ state: Bool) {
        guard isLoadingPhrase != state else { return }
        isLoadingPhrase = state
    }
}
