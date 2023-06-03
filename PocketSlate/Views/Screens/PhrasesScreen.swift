//
//  PhrasesScreen.swift
//  PocketSlate
//
//  Created by Kamaal Farah on 28/05/2023.
//

import SwiftUI
import KamaalUI
import KamaalLogger
import KamaalExtensions

private let logger = KamaalLogger(from: PhrasesScreen.self, failOnError: true)

struct PhrasesScreen: View {
    @Environment(\.colorScheme) private var colorScheme

    @EnvironmentObject private var userData: UserData

    @StateObject private var viewModel = ViewModel()

    var body: some View {
        VStack {
            LocaleSelectors(
                primaryLocale: viewModel.primaryLocale,
                secondaryLocale: viewModel.secondaryLocale,
                selectedLocaleSelector: viewModel.selectedLocaleSelector,
                selectLocaleSelector: { viewModel.selectLocaleSelector($0) }
            )
            Spacer()
                .ktakeSizeEagerly()
        }
        .sheet(isPresented: $viewModel.localeSelectorSheetIsShown) {
            LocaleSelectorSheet(
                locales: viewModel.selectedLocaleSelectorLocales,
                onClose: { viewModel.closeLocaleSelectorSheet() },
                onLocaleSelect: { locale in viewModel.selectLocale(locale) }
            )
        }
    }
}

extension PhrasesScreen {
    final class ViewModel: ObservableObject {
        @Published private(set) var primaryLocale: Locale
        @Published private(set) var secondaryLocale: Locale

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

            return Self.locales
                .filter { $0 != currentLocale }
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

            var newPrimaryLocale: Locale
            var newSecondaryLocale: Locale
            switch selectedLocaleSelector {
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
                UserDefaults.primaryLocale = newPrimaryLocale
                primaryLocale = newPrimaryLocale
            }

            if newSecondaryLocale != secondaryLocale {
                UserDefaults.secondaryLocale = newSecondaryLocale
                secondaryLocale = newSecondaryLocale
            }

            logger.info("Updated \(selectedLocaleSelector.rawValue) locale to '\(locale.identifier)'")
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

            guard let shortenedPreferredLocaleIdentifier = Locale.current.identifier.split(separator: "_").first
            else { return combinedLocales }

            let preferredLocale = Locale(identifier: String(shortenedPreferredLocaleIdentifier))
            guard let preferredLocaleIndex = combinedLocales.findIndex(by: \.identifier, is: preferredLocale.identifier)
            else { return combinedLocales }

            return combinedLocales
                .removed(at: preferredLocaleIndex)
                .prepended(preferredLocale)
        }()

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

struct PhrasesScreen_Previews: PreviewProvider {
    static var previews: some View {
        PhrasesScreen()
            .environmentObject(UserData())
    }
}
