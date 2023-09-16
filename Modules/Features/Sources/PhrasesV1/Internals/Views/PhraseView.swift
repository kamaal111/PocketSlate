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
import AVFoundation
import KamaalExtensions

private let logger = KamaalLogger(from: PhraseView.self, failOnError: true)

struct PhraseView: View {
    @Environment(\.editMode) var editMode
    @Environment(\.isEnabled) var isEnabled

    @EnvironmentObject private var userData: UserData

    @State private var deletionConfirmation = false

    @Binding var editingPrimaryField: String
    @Binding var editingSecondaryField: String

    let phrase: AppPhrase
    let primaryLocale: Locale
    let secondaryLocale: Locale
    let isEditingText: Bool
    let supportedTranslatableLocales: [Locale]
    let onEditText: (_ phrase: AppPhrase) -> Void
    let onDeleteTranslation: (_ phrase: AppPhrase) -> Void
    let translateText: (_ phrase: AppPhrase, _ sourceLocale: Locale, _ targetLocale: Locale) -> Void

    var body: some View {
        HStack {
            phraseTextView(primaryLocale, sourceLocale: secondaryLocale, editingText: $editingPrimaryField)
            SplitterView()
            phraseTextView(secondaryLocale, sourceLocale: primaryLocale, editingText: $editingSecondaryField)
            if editMode?.isEditing ?? false, !isEditingText {
                HStack {
                    #if os(macOS)
                    editActionButton(imageSystemName: "pencil", action: { onEditText(phrase) })
                    #endif
                    editActionButton(imageSystemName: "trash.fill", action: { deletionConfirmation = true })
                }
            }
        }
        #if os(macOS)
        .padding(.horizontal, .small)
        #endif
        .confirmationDialog(
            AppLocales.getText(.PHRASE_DELETION_CONFIRMATION_TITLE),
            isPresented: $deletionConfirmation,
            actions: {
                Button(AppLocales.getText(.SURE), role: .destructive, action: handleDefiniteDeletion)
                    .foregroundColor(.red)
            },
            message: { Text(localized: .PHRASE_DELETION_CONFIRMATION_MESSAGE) }
        )
    }

    private func editActionButton(imageSystemName: String, action: @escaping () -> Void) -> some View {
        #if os(macOS)
        Button(action: action) {
            Image(systemName: imageSystemName)
                .kBold()
                .foregroundColor(.accentColor)
        }
        #else
        Image(systemName: imageSystemName)
            .kBold()
            .foregroundColor(.accentColor)
            .onTapGesture(perform: action)
        #endif
    }

    private func phraseTextView(_ locale: Locale, sourceLocale: Locale, editingText: Binding<String>) -> some View {
        KJustStack {
            if editMode?.isEditing == true, isEditingText {
                KFloatingTextField(
                    text: editingText,
                    title: userData.appLocale.localizedString(forIdentifier: locale.identifier)!
                )
            } else {
                HStack {
                    if phrase.translations[sourceLocale]?.trimmingByWhitespacesAndNewLines.isEmpty == false,
                       supportedTranslatableLocales.contains(locale) {
                        Image(systemName: "globe")
                            .kBold()
                            .foregroundColor(.accentColor)
                            .onTapGesture { translateText(phrase, sourceLocale, locale) }
                    }
                    if let text = phrase.translations[locale], !text.isEmpty {
                        Text(text)
                        Spacer()
                        if editMode?.isEditing == false {
                            Image(systemName: "speaker.wave.3")
                                .kBold()
                                .foregroundColor(isEnabled ? .accentColor : .secondary)
                                .onTapGesture { speakOut(text: text, with: locale) }
                        }
                    } else {
                        Text(localized: .NOT_SET)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .ktakeWidthEagerly(alignment: .leading)
        #if os(iOS)
            .onTapGesture(perform: {
                if editMode?.isEditing == true {
                    onEditText(phrase)
                }
            })
        #endif
    }

    private func speakOut(text: String, with locale: Locale) {
        let utterance = AVSpeechUtterance(string: text)
        let voice = AVSpeechSynthesisVoice(language: locale.identifier)
        utterance.voice = voice
        utterance.rate = 0.2

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }

    private func handleDefiniteDeletion() {
        onDeleteTranslation(phrase)
        deletionConfirmation = false
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
                creationDate: Date(timeIntervalSince1970: 1_687_286_860),
                updatedDate: Date(timeIntervalSince1970: 1_687_286_860),
                translations: [
                    primaryLocale: "Hello",
                    secondaryLocale: "Ciao",
                ],
                source: .userDefaults
            ),
            primaryLocale: primaryLocale,
            secondaryLocale: secondaryLocale,
            isEditingText: false,
            supportedTranslatableLocales: [],
            onEditText: { _ in },
            onDeleteTranslation: { _ in },
            translateText: { _, _, _ in }
        )
    }
}
