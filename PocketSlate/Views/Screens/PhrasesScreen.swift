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
            ZStack {
                HStack {
                    LocaleSelector(
                        currentLocale: viewModel.primaryLocale,
                        isSelected: viewModel.selectedLocaleSelector == .primary,
                        action: { viewModel.selectLocaleSelector(.primary) }
                    )
                    LocaleSelector(
                        currentLocale: viewModel.secondaryLocale,
                        isSelected: viewModel.selectedLocaleSelector == .secondary,
                        action: { viewModel.selectLocaleSelector(.secondary) }
                    )
                }
            }
            .padding(.vertical, .small)
            .background(colorScheme == .dark ? Color.black : Color.gray.opacity(0.1))
            .ktakeWidthEagerly()
            Spacer()
                .ktakeSizeEagerly()
        }
    }
}

extension PhrasesScreen {
    final class ViewModel: ObservableObject {
        @Published private(set) var selectedLocaleSelector: LocaleSelectorType?
        @Published private(set) var primaryLocale = ViewModel.locales.last!
        @Published private(set) var secondaryLocale = ViewModel.locales.first!

        @MainActor
        func selectLocaleSelector(_ selector: LocaleSelectorType) {
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
    }
}

extension PhrasesScreen {
    enum LocaleSelectorType {
        case primary
        case secondary
    }
}

struct PhrasesScreen_Previews: PreviewProvider {
    static var previews: some View {
        PhrasesScreen()
            .environmentObject(UserData())
    }
}
