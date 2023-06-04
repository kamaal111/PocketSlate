//
//  PhraseView.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 04/06/2023.
//

import SwiftUI
import KamaalUI

struct PhraseView: View {
    let phrase: AppPhrase
    let primaryLocale: Locale
    let secondaryLocale: Locale

    var body: some View {
        HStack {
            KJustStack {
                if let primaryPhrase = phrase.translations[primaryLocale]?.first {
                    Text(primaryPhrase)
                } else {
                    Text(localized: .NOT_SET)
                        .foregroundColor(.secondary)
                }
            }
            .ktakeWidthEagerly()
            KJustStack {
                if let secondaryPhrase = phrase.translations[secondaryLocale]?.first {
                    Text(secondaryPhrase)
                } else {
                    Text(localized: .NOT_SET)
                        .foregroundColor(.secondary)
                }
            }
            .ktakeWidthEagerly()
        }
    }
}

struct PhraseView_Previews: PreviewProvider {
    static let primaryLocale = Locale(identifier: "en")
    static let secondaryLocale = Locale(identifier: "it")

    static var previews: some View {
        PhraseView(
            phrase: AppPhrase(
                id: UUID(uuidString: "d5b8c209-e65b-497f-a9e7-f121995ff13d")!,
                translations: [
                    primaryLocale: ["Hello"],
                    secondaryLocale: ["Ciao"],
                ]
            ),
            primaryLocale: primaryLocale,
            secondaryLocale: secondaryLocale
        )
    }
}
