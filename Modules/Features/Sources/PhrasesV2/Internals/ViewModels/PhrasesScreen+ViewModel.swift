//
//  PhrasesScreen+ViewModel.swift
//
//
//  Created by Kamaal M Farah on 16/09/2023.
//

import AppUI
import Models
import SwiftUI
import Observation
import KamaalLogger
import PocketSlateAPI
import KamaalExtensions

private let logger = KamaalLogger(from: PhrasesScreen.self, failOnError: true)

extension PhrasesScreen {
    @Observable
    final class ViewModel {
        private(set) var locales: Pair<Locale>
        private(set) var selectedLocaleSelector: LocaleSelectorTypes?
        private(set) var supportedTranslatableLocales: [Locale] = []
        var editMode: EditMode = .inactive
        var newPrimaryPhrase = ""
        var newSecondaryPhrase = ""
        var localeSelectorSheetIsShown = false

        private var previouslySelectedLocales: [Locale]
        private var pocketSlateAPI: PocketSlateAPI?

        convenience init() {
            let initialLocales = Self.getInitialLocales()
            self.init(locales: initialLocales)
        }

        private init(locales: Pair<Locale>) {
            self.locales = locales
            self.previouslySelectedLocales = UserDefaults.previouslySelectedLocales ?? []
            if let secrets = SecretsJSON.shared.content, let apiKey = secrets.apiKey, let apiURL = secrets.apiURL {
                self.pocketSlateAPI = PocketSlateAPI(apiKey: apiKey, apiURL: apiURL)
            }
        }

        var appLocalePair: Pair<AppLocale> {
            Pair(
                primary: AppLocale(
                    value: locales.primary,
                    isTranslatable: supportedTranslatableLocales.contains(locales.primary)
                ),
                secondary: AppLocale(
                    value: locales.secondary,
                    isTranslatable: supportedTranslatableLocales.contains(locales.secondary)
                )
            )
        }

        var newPhrasePair: Pair<String?> {
            let trimmedPrimary = newPrimaryPhrase.trimmingByWhitespacesAndNewLines
            let primary: String? = if trimmedPrimary.isEmpty { nil } else { trimmedPrimary }
            let trimmedSecondary = newSecondaryPhrase.trimmingByWhitespacesAndNewLines
            let secondary: String? = if trimmedSecondary.isEmpty { nil } else { trimmedSecondary }

            return .init(primary: primary, secondary: secondary)
        }

        var selectedLocaleSelectorLocales: [Locale] {
            guard let selectedLocaleSelector else {
                logger.error("Failed to know which selector has been selected")
                return Self.locales
            }

            let currentLocale: Locale
            switch selectedLocaleSelector {
            case .primary: currentLocale = locales.primary
            case .secondary: currentLocale = locales.secondary
            }

            return previouslySelectedLocales
                .concat(Self.locales)
                .filter { $0 != currentLocale }
                .uniques()
        }

        @MainActor
        func clearNewPhraseFields() {
            newPrimaryPhrase = ""
            newSecondaryPhrase = ""
        }

        func fetchSupportedTranslationLocales(forTargetLocale targetLocale: Locale) async {
            guard let api = pocketSlateAPI else {
                logger.warning("Pocket slate api not configured")
                return
            }

            let result = await api.translation.getSupportedLocales(as: targetLocale)
            let supportedLocales: [SupportedLocale]
            switch result {
            case let .failure(failure):
                logger.error(label: "Failed to get supported locales", error: failure)
                return
            case let .success(success): supportedLocales = success
            }

            await setSupportedTranslatebleLocales(supportedLocales.map(\.tag))
        }

        @MainActor
        func swapLocales() {
            setLocales(locales.swapped())
        }

        @MainActor
        func selectLocale(_ locale: Locale) {
            guard let selectedLocaleSelector else {
                closeLocaleSelectorSheet()
                logger.error("Failed to know which selector has been selected")
                return
            }

            setSelectedLocale(locale, localeSelector: selectedLocaleSelector)
            closeLocaleSelectorSheet()
        }

        @MainActor
        func selectLocaleSelector(_ selector: LocaleSelectorTypes) {
            withAnimation { self.selectedLocaleSelector = selector }
            openLocaleSelectorSheet()
        }

        @MainActor
        func closeLocaleSelectorSheet() {
            localeSelectorSheetIsShown = false
            selectedLocaleSelector = nil
        }

        @MainActor
        private func openLocaleSelectorSheet() {
            localeSelectorSheetIsShown = true
        }

        @MainActor
        private func setSupportedTranslatebleLocales(_ locales: [Locale]) {
            supportedTranslatableLocales = locales
        }

        @MainActor
        private func setSelectedLocale(_ locale: Locale, localeSelector: LocaleSelectorTypes) {
            var newLocales: Pair<Locale>
            switch localeSelector {
            case .primary:
                newLocales = .init(primary: locale, secondary: locales.secondary)
                if newLocales.primary == newLocales.secondary {
                    newLocales = newLocales.setSecondary(with: locales.primary)
                }
            case .secondary:
                newLocales = .init(primary: locales.primary, secondary: locale)
                if newLocales.primary == newLocales.secondary {
                    newLocales = newLocales.setPrimary(with: locales.secondary)
                }
            }

            if newLocales != locales {
                setLocales(newLocales)
            }
        }

        @MainActor
        private func setLocales(_ locales: Pair<Locale>) {
            self.locales = locales
            UserDefaults.primaryLocale = locales.primary
            UserDefaults.secondaryLocale = locales.secondary
        }

        static let locales: [Locale] = {
            let languages = Constants.priorityLanguages
            let groupedIdentifiers = Locale.availableIdentifiers
                .reduce((primary: [Locale](), sub: [Locale]())) { result, identifier in
                    let locale = Locale(identifier: identifier)
                    guard !languages.contains(locale) else { return result }

                    let splittedIdentifer = identifier.split(separator: "_")
                    if splittedIdentifer.count == 1 {
                        return (result.primary.appended(locale), result.sub)
                    }

                    return result
                }
            let combinedLocales = languages
                .concat(groupedIdentifiers.primary.sorted())
                .concat(groupedIdentifiers.sub.sorted())
                .uniques()
            let shortenedPreferredLocaleIdentifier = Locale.current.identifier.split(separator: "_")[0]
            let preferredLocale = Locale(identifier: String(shortenedPreferredLocaleIdentifier))
            guard let preferredLocaleIndex = combinedLocales
                .findIndex(by: \.identifier, is: preferredLocale.identifier) else {
                logger.error("preferred locale identifier index is not present")
                return combinedLocales
            }

            return combinedLocales
                .removed(at: preferredLocaleIndex)
                .prepended(preferredLocale)
        }()

        private static func getInitialLocales() -> Pair<Locale> {
            let preferredLocale = locales.first!
            var primaryLocale = UserDefaults.primaryLocale
            if primaryLocale == nil {
                primaryLocale = preferredLocale
                UserDefaults.primaryLocale = primaryLocale
            }
            var secondaryLocale = UserDefaults.secondaryLocale
            if secondaryLocale == nil || secondaryLocale == primaryLocale {
                if primaryLocale == preferredLocale {
                    secondaryLocale = locales[1]
                } else {
                    secondaryLocale = preferredLocale
                }
                UserDefaults.secondaryLocale = secondaryLocale
            }

            return .init(primary: primaryLocale!, secondary: secondaryLocale!)
        }
    }
}
