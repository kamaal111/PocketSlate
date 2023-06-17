//
//  PhraseView.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 04/06/2023.
//

import Users
import AppUI
import SwiftUI
import KamaalUI
import AppLocales
import KamaalLogger

private let logger = KamaalLogger(from: PhraseView.self, failOnError: true)

struct PhraseView: View {
    @Environment(\.editMode) var editMode

    @EnvironmentObject private var userData: UserData

    @Binding var editingPrimaryField: String
    @Binding var editingSecondaryField: String

    let phrase: AppPhrase
    let primaryLocale: Locale
    let secondaryLocale: Locale
    let isSelected: Bool
    let onSelection: (_ phrase: AppPhrase) -> Void

    var body: some View {
        HStack {
            phraseTextView(primaryLocale, editingText: $editingPrimaryField)
            phraseTextView(secondaryLocale, editingText: $editingSecondaryField)
        }
        .padding(.horizontal, .medium)
    }

    private func phraseTextView(_ locale: Locale, editingText: Binding<String>) -> some View {
        KJustStack {
            if editMode?.isEditing ?? false, isSelected {
                KFloatingTextField(
                    text: editingText,
                    title: userData.appLocale.localizedString(forIdentifier: locale.identifier)!
                )
            } else {
                if let text = phrase.translations[locale]?.first {
                    Text(text)
                } else {
                    Text(localized: .NOT_SET)
                        .foregroundColor(.secondary)
                }
            }
        }
        .ktakeWidthEagerly()
        .onTapGesture(perform: { handleOnTap() })
    }

    private func handleOnTap() {
        guard let editMode else {
            logger.error("No edit mode environment set")
            return
        }

        guard editMode.isEditing else { return }

        onSelection(phrase)
    }
}

struct PhraseView_Previews: PreviewProvider {
    static let primaryLocale = Locale(identifier: "en")
    static let secondaryLocale = Locale(identifier: "it")

    static var previews: some View {
        PhraseView(
            editingPrimaryField: .constant("Hello"),
            editingSecondaryField: .constant("Ciao"),
            phrase: AppPhrase(
                id: UUID(uuidString: "d5b8c209-e65b-497f-a9e7-f121995ff13d")!,
                translations: [
                    primaryLocale: ["Hello"],
                    secondaryLocale: ["Ciao"],
                ]
            ),
            primaryLocale: primaryLocale,
            secondaryLocale: secondaryLocale,
            isSelected: false,
            onSelection: { _ in }
        )
    }
}
