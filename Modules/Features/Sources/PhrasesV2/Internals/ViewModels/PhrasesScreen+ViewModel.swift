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
        private(set) var locales: (primary: Locale, secondary: Locale)
        private(set) var selectedLocaleSelector: LocaleSelectorTypes?
        var editMode: EditMode = .inactive
        var newPrimaryPhrase = ""
        var newSecondaryPhrase = ""

        private var previouslySelectedLocales: [Locale]

        convenience init() {
            let initialLocales = Self.getInitialLocales()
            self.init(locales: initialLocales)
        }

        private init(locales: (primary: Locale, secondary: Locale)) {
            self.locales = locales
            self.previouslySelectedLocales = UserDefaults.previouslySelectedLocales ?? []
        }

        @MainActor
        func swapLocales() {
            locales = (locales.secondary, locales.primary)
        }

        @MainActor
        func selectLocaleSelector(_ selector: LocaleSelectorTypes) {
            withAnimation { self.selectedLocaleSelector = selector }
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

        private static func getInitialLocales() -> (primary: Locale, secondary: Locale) {
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

            return (primaryLocale!, secondaryLocale!)
        }
    }
}
