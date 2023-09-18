//
//  PhraseView.swift
//
//
//  Created by Kamaal M Farah on 18/09/2023.
//

import AppUI
import Models
import SwiftUI
import SwiftData
import Persistance
import KamaalExtensions

struct PhraseView: View {
    @State private var deletionConfirmation = false

    let phrase: AppPhrase
    let locales: Pair<AppLocale>
    let onDeleteTranslation: (_ phrase: AppPhrase) -> Void
    let translateText: (_ phrase: AppPhrase, _ sourceLocale: Locale, _ targetLocale: Locale) -> Void

    var body: some View {
        HStack {
            PhraseTextView(
                translation: phrase.translations?.find(by: \.locale, is: locales.primary.value)?.value,
                sourceLocale: locales.primary.value,
                targetLocale: locales.secondary.value,
                isTranslatable: locales.primary.isTranslatable,
                translateText: { translateText(phrase, locales.primary.value, locales.secondary.value) }
            )
            SplitterView()
            PhraseTextView(
                translation: phrase.translations?.find(by: \.locale, is: locales.secondary.value)?.value,
                sourceLocale: locales.secondary.value,
                targetLocale: locales.primary.value,
                isTranslatable: locales.secondary.isTranslatable,
                translateText: { translateText(phrase, locales.secondary.value, locales.primary.value) }
            )
        }
        #if os(macOS)
        .padding(.horizontal, .small)
        #endif
        .confirmationDialog(
            NSLocalizedString("Delete phrase", bundle: .module, comment: ""),
            isPresented: $deletionConfirmation,
            actions: {
                Button(
                    NSLocalizedString("Sure", bundle: .module, comment: ""),
                    role: .destructive,
                    action: handleDefiniteDeletion
                )
                .foregroundColor(.red)
            },
            message: { Text("Are you sure want to delete these phrases?", bundle: .module) }
        )
    }

    private func handleDefiniteDeletion() {
        onDeleteTranslation(phrase)
        deletionConfirmation = false
    }
}

// #Preview {
//    PhraseView(phrase: PreviewData.phrases[0])
//        .modelContainer(for: [AppPhrase.self, AppTranslation.self], inMemory: true)
// }
