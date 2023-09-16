//
//  LocaleSelectors.swift
//
//
//  Created by Kamaal M Farah on 16/09/2023.
//

import AppUI
import SwiftUI
import KamaalUI

struct LocaleSelectors: View {
    let locales: (primary: Locale, secondary: Locale)
    let selectedLocaleSelector: LocaleSelectorTypes?
    let swapLocales: () -> Void
    let selectLocaleSelector: (_ selector: LocaleSelectorTypes) -> Void

    var body: some View {
        HStack {
            LocaleSelector(
                currentLocale: locales.primary,
                isSelected: selectedLocaleSelector == .primary,
                action: { selectLocaleSelector(.primary) }
            )
            Button(action: swapLocales) {
                Image(systemName: "arrow.left.arrow.right")
                    .kBold()
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            LocaleSelector(
                currentLocale: locales.secondary,
                isSelected: selectedLocaleSelector == .secondary,
                action: { selectLocaleSelector(.secondary) }
            )
        }
        .padding(.vertical, .small)
        .backgroundColor(light: .secondaryBackground.light, dark: .secondaryBackground.dark)
        .ktakeWidthEagerly()
    }
}

#if DEBUG
import Users

#Preview {
    LocaleSelectors(
        locales: (PreviewData.locales.first!, PreviewData.locales.last!),
        selectedLocaleSelector: .primary,
        swapLocales: { },
        selectLocaleSelector: { _ in }
    )
    .usersEnvironment()
}
#endif
