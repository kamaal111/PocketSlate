//
//  LocaleSelectorSheet.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 29/05/2023.
//

import SwiftUI
import KamaalUI
import AppLocales
import KamaalAlgorithms
import KamaalExtensions

struct LocaleSelectorSheet: View {
    @EnvironmentObject private var userData: UserData

    @State private var searchTerm = ""

    let locales: [Locale]
    let onClose: () -> Void
    let onLocaleSelect: (_ locale: Locale) -> Void

    var body: some View {
        KSheetStack(
            title: AppLocales.getText(.LANGUAGES),
            leadingNavigationButton: { leadingNavigationButton },
            trailingNavigationButton: { Text.empty() }
        ) {
            VStack {
                KFloatingTextField(text: $searchTerm, title: AppLocales.getText(.SEARCH))
                ScrollView {
                    ForEach(filteredLocales, id: \.identifier) { locale in
                        localeButton(locale)
                    }
                    if filteredLocales.isEmpty {
                        Text(localized: .NO_LOCALE_SEARCH_MATCH, with: [searchTerm])
                        clearSearchButton
                    }
                }
                .ktakeWidthEagerly()
            }
            .padding(.vertical, .medium)
        }
        .backgroundColor(light: .secondaryBackground.light, dark: .secondaryBackground.dark)
        #if os(macOS)
            .frame(minWidth: 300, minHeight: 200, maxHeight: 400)
        #endif
    }

    private var leadingNavigationButton: some View {
        Button(action: onClose) {
            Text(localized: .CLOSE)
                .foregroundColor(.accentColor)
                .bold()
        }
    }

    private var clearSearchButton: some View {
        Button(action: clearSearchTerm) {
            HStack(spacing: 0) {
                Text(localized: .CLEAR_SEARCH)
                    .bold()
                    .padding(.trailing, .extraExtraSmall)
                Image(systemName: "eraser.fill")
                    .kBold()
            }
            .foregroundColor(.accentColor)
        }
        .buttonStyle(.plain)
    }

    private func localeButton(_ locale: Locale) -> some View {
        Button(action: { onLocaleSelect(locale) }) {
            Text(makeMessage(from: locale))
                .foregroundColor(.accentColor)
                .bold()
                .padding(.vertical, .extraExtraSmall)
                .padding(.horizontal, .small)
                .ktakeWidthEagerly(alignment: .leading)
                .backgroundColor(light: .secondaryItemBackground.light, dark: .secondaryItemBackground.dark)
                .cornerRadius(.extraSmall)
        }
        .buttonStyle(.plain)
    }

    private var filteredLocales: [Locale] {
        let searchTerm = searchTerm.replacingOccurrences(of: " ", with: "")
        guard !searchTerm.isEmpty else { return locales }

        return locales
            .filter {
                let identifier = $0.identifier
                return identifier.fuzzyMatch(searchTerm) || userData.appLocale
                    .localizedString(forIdentifier: identifier)!
                    .replacingOccurrences(of: " ", with: "")
                    .fuzzyMatch(searchTerm)
            }
    }

    private func clearSearchTerm() {
        searchTerm = ""
    }

    private func makeMessage(from locale: Locale) -> String {
        "\(locale.identifier) - \(userData.appLocale.localizedString(forIdentifier: locale.identifier)!)"
    }
}

struct LocaleSelectorSheet_Previews: PreviewProvider {
    static var previews: some View {
        LocaleSelectorSheet(locales: PhrasesScreen.ViewModel.locales, onClose: { }, onLocaleSelect: { _ in })
            .environmentObject(UserData())
    }
}
