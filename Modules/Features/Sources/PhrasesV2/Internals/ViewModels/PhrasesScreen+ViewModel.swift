//
//  PhrasesScreen+ViewModel.swift
//
//
//  Created by Kamaal M Farah on 16/09/2023.
//

import AppUI
import SwiftUI
import Observation
import KamaalLogger
import KamaalExtensions

private let logger = KamaalLogger(from: PhrasesScreen.self, failOnError: true)

extension PhrasesScreen {
    @Observable
    final class ViewModel {
        private(set) var locales: LocalePair
        private(set) var selectedLocaleSelector: LocaleSelectorTypes?
        private(set) var supportedTranslatableLocales: [Locale] = []
        var editMode: EditMode = .inactive
        var newPrimaryPhrase = ""
        var newSecondaryPhrase = ""
        var localeSelectorSheetIsShown = false

        private var previouslySelectedLocales: [Locale]

        convenience init() {
            let initialLocales = Self.getInitialLocales()
            self.init(locales: initialLocales)
        }

        private init(locales: LocalePair) {
            self.locales = locales
            self.previouslySelectedLocales = UserDefaults.previouslySelectedLocales ?? []
        }

        var selectedLocaleSelectorLocales: [Locale] {
            guard let selectedLocaleSelector else {
                logger.error("Failed to know which selector has been selected")
                return Self.locales
            }

            let currentLocale: Locale
            switch selectedLocaleSelector {
            case .primary:
                currentLocale = locales.primary
            case .secondary:
                currentLocale = locales.secondary
            }

            return previouslySelectedLocales
                .concat(Self.locales)
                .filter { $0 != currentLocale }
                .uniques()
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
        private func setSelectedLocale(_ locale: Locale, localeSelector: LocaleSelectorTypes) {
            var newLocales: LocalePair
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
        private func setLocales(_ locales: LocalePair) {
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

        private static func getInitialLocales() -> LocalePair {
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
