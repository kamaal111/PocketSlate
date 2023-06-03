//
//  LocaleSelectorSheet.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 29/05/2023.
//

import SwiftUI
import KamaalUI
import AppLocales

struct LocaleSelectorSheet: View {
    @EnvironmentObject private var userData: UserData

    let locales: [Locale]
    let onClose: () -> Void
    let onLocaleSelect: (_ locale: Locale) -> Void

    var body: some View {
        KSheetStack(
            title: AppLocales.getText(.LANGUAGES),
            leadingNavigationButton: { leadingNavigationButton },
            trailingNavigationButton: { Text.empty() }
        ) {
            ScrollView {
                ForEach(locales, id: \.identifier) { locale in
                    localeButton(locale)
                }
            }
            .ktakeWidthEagerly()
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
