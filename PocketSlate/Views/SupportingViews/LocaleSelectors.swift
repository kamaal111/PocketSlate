//
//  LocaleSelectors.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 29/05/2023.
//

import SwiftUI
import KamaalUI

struct LocaleSelectors: View {
    @Environment(\.colorScheme) private var colorScheme

    let primaryLocale: Locale
    let secondaryLocale: Locale
    let selectedLocaleSelector: LocaleSelectorTypes?
    let selectLocaleSelector: (_ selector: LocaleSelectorTypes) -> Void

    var body: some View {
        HStack {
            LocaleSelector(
                currentLocale: primaryLocale,
                isSelected: selectedLocaleSelector == .primary,
                action: { selectLocaleSelector(.primary) }
            )
            LocaleSelector(
                currentLocale: secondaryLocale,
                isSelected: selectedLocaleSelector == .secondary,
                action: { selectLocaleSelector(.secondary) }
            )
        }
        .padding(.vertical, .small)
        .background(colorScheme == .dark ? Color.black : Color.gray.opacity(0.1))
        .ktakeWidthEagerly()
    }
}

struct LocaleSelectors_Previews: PreviewProvider {
    static var previews: some View {
        LocaleSelectors(
            primaryLocale: PhrasesScreen.ViewModel.locales.first!,
            secondaryLocale: PhrasesScreen.ViewModel.locales.last!,
            selectedLocaleSelector: .primary,
            selectLocaleSelector: { _ in }
        )
    }
}
