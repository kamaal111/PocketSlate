//
//  PhrasesScreen+ViewModel.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 04/06/2023.
//

import SwiftUI
import KamaalLogger
import KamaalExtensions

private let logger = KamaalLogger(from: PhrasesScreen.self, failOnError: true)

extension PhrasesScreen {
    final class ViewModel: ObservableObject {
        @Published private(set) var primaryLocale: Locale {
            didSet { primaryLocaleDidSet() }
        }

        @Published private(set) var secondaryLocale: Locale {
            didSet { secondaryLocaleDidSet() }
        }

        @Published private var previouslySelectedLocales: [Locale] {
            didSet { previouslySelectedLocalesDidSet() }
        }

        @Published var localeSelectorSheetIsShown = false {
            didSet { Task { await localeSelectorSheetIsShownDidSet() } }
        }

        @Published private(set) var selectedLocaleSelector: LocaleSelectorTypes? {
            didSet { Task { await selectedLocaleSelectorDidSet() } }
        }

        init() {
            let (primaryLocale, secondaryLocale) = Self.getInitialLocales()
            self.primaryLocale = primaryLocale
            self.secondaryLocale = secondaryLocale
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
                currentLocale = primaryLocale
            case .secondary:
                currentLocale = secondaryLocale
            }

            return previouslySelectedLocales
                .concat(Self.locales)
                .filter { $0 != currentLocale }
                .uniques()
        }

        @MainActor
        func swapLocales() {
            let newPrimaryLocale = secondaryLocale
            let newSecondaryLocale = primaryLocale
            primaryLocale = newPrimaryLocale
            secondaryLocale = newSecondaryLocale
        }

        @MainActor
        func selectLocaleSelector(_ selector: LocaleSelectorTypes) {
            withAnimation { self.selectedLocaleSelector = selector }
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
        func closeLocaleSelectorSheet() {
            localeSelectorSheetIsShown = false
        }

        @MainActor
        func openLocaleSelectorSheet() {
            localeSelectorSheetIsShown = true
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

                    if !Features.showSubLocales {
                        return result
                    }

                    return (result.primary, result.sub.appended(locale))
                }

            let combinedLocales = languages
                .concat(groupedIdentifiers.primary.sorted())
                .concat(groupedIdentifiers.sub.sorted())
                .uniques()

            guard let shortenedPreferredLocaleIdentifier = Locale.current.identifier.split(separator: "_").first else {
                logger.error("shortend preferred locale identifier should have been present")
                return combinedLocales
            }

            let preferredLocale = Locale(identifier: String(shortenedPreferredLocaleIdentifier))
            guard let preferredLocaleIndex = combinedLocales
                .findIndex(by: \.identifier, is: preferredLocale.identifier) else {
                logger.error("preferred locale identifier index should have been present")
                return combinedLocales
            }

            return combinedLocales
                .removed(at: preferredLocaleIndex)
                .prepended(preferredLocale)
        }()

        @MainActor
        private func setSelectedLocale(_ locale: Locale, localeSelector: LocaleSelectorTypes) {
            var newPrimaryLocale: Locale
            var newSecondaryLocale: Locale
            switch localeSelector {
            case .primary:
                newPrimaryLocale = locale
                newSecondaryLocale = secondaryLocale
                if newPrimaryLocale == newSecondaryLocale {
                    newSecondaryLocale = primaryLocale
                }
            case .secondary:
                newPrimaryLocale = primaryLocale
                newSecondaryLocale = locale
                if newPrimaryLocale == newSecondaryLocale {
                    newPrimaryLocale = secondaryLocale
                }
            }

            if newPrimaryLocale != primaryLocale {
                primaryLocale = newPrimaryLocale
            }

            if newSecondaryLocale != secondaryLocale {
                secondaryLocale = newSecondaryLocale
            }

            previouslySelectedLocales = previouslySelectedLocales
                .prepended(locale)
                .uniques()

            logger.info("Updated \(localeSelector.rawValue) locale to '\(locale.identifier)'")
        }

        @MainActor
        private func localeSelectorSheetIsShownDidSet() {
            if !localeSelectorSheetIsShown, selectedLocaleSelector != nil {
                selectedLocaleSelector = nil
            }
        }

        @MainActor
        private func selectedLocaleSelectorDidSet() {
            if selectedLocaleSelector != nil {
                if !localeSelectorSheetIsShown {
                    openLocaleSelectorSheet()
                }
                return
            }

            if localeSelectorSheetIsShown {
                closeLocaleSelectorSheet()
            }
        }

        private func primaryLocaleDidSet() {
            UserDefaults.primaryLocale = primaryLocale
        }

        private func secondaryLocaleDidSet() {
            UserDefaults.secondaryLocale = secondaryLocale
        }

        private func previouslySelectedLocalesDidSet() {
            UserDefaults.previouslySelectedLocales = previouslySelectedLocales
        }

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
                    secondaryLocale = locales.at(1)!
                } else {
                    secondaryLocale = preferredLocale
                }
                UserDefaults.secondaryLocale = secondaryLocale!
            }

            return (primaryLocale!, secondaryLocale!)
        }
    }
}
