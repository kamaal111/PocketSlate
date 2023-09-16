//
//  PhrasesScreen.swift
//
//
//  Created by Kamaal M Farah on 16/09/2023.
//

import SwiftUI

public struct PhrasesScreen: View {
    public init() { }

    public var body: some View {
        VStack {
            LocaleSelectors(
                locales: (PreviewData.locales.first!, PreviewData.locales.last!),
                selectedLocaleSelector: .primary,
                swapLocales: { },
                selectLocaleSelector: { _ in }
            )
        }
    }
}

#if DEBUG
import Users

#Preview {
    PhrasesScreen()
        .usersEnvironment()
}
#endif
