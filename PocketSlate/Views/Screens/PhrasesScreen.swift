//
//  PhrasesScreen.swift
//  PocketSlate
//
//  Created by Kamaal Farah on 28/05/2023.
//

import SwiftUI
import KamaalUI
import KamaalExtensions

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
            LocaleSelectorSheet(onClose: { viewModel.closeLocaleSelectorSheet() })
        }
    }
}

extension PhrasesScreen {
    final class ViewModel: ObservableObject {
        @Published private(set) var selectedLocaleSelector: LocaleSelectorTypes? {
            didSet { Task { await selectedLocaleSelectorDidSet() } }
        }

        @Published private(set) var primaryLocale = ViewModel.locales.last!
        @Published private(set) var secondaryLocale = ViewModel.locales.first!
        @Published var localeSelectorSheetIsShown = false {
            didSet { Task { await localeSelectorSheetIsShownDidSet() } }
        }

        @MainActor
        func selectLocaleSelector(_ selector: LocaleSelectorTypes) {
            withAnimation { self.selectedLocaleSelector = selector }
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
    }
}

struct PhrasesScreen_Previews: PreviewProvider {
    static var previews: some View {
        PhrasesScreen()
            .environmentObject(UserData())
    }
}
