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
    @Environment(\.editMode) private var editMode

    @State private var deletionConfirmation = false

    @Binding var editingPrimaryText: String
    @Binding var editingSecondaryText: String

    let phrase: AppPhrase
    let locales: Pair<AppLocale>
    let isEditingText: Bool
    let onDeleteTranslation: () -> Void
    let translateText: (_ sourceLocale: Locale, _ targetLocale: Locale) -> Void
    let onEditSelect: () -> Void
    let phraseTranslationToDisplay: (_ locale: Locale) -> String

    var body: some View {
        HStack {
            PhraseTextView(
                editingText: $editingPrimaryText,
                translation: phraseTranslationToDisplay(locales.primary.value),
                locale: locales.primary.value,
                isTranslatable: locales.primary.isTranslatable,
                isEditingText: isEditingText,
                translateText: { translateText(locales.primary.value, locales.secondary.value) },
                onEditSelect: onEditSelect
            )
            SplitterView()
            PhraseTextView(
                editingText: $editingSecondaryText,
                translation: phraseTranslationToDisplay(locales.secondary.value),
                locale: locales.secondary.value,
                isTranslatable: locales.secondary.isTranslatable,
                isEditingText: isEditingText,
                translateText: { translateText(locales.secondary.value, locales.primary.value) },
                onEditSelect: onEditSelect
            )
            if editMode?.isEditing == true, !isEditingText {
                Spacer()
                editButtons
            }
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

    private var editButtons: some View {
        HStack {
            #if os(macOS)
            editActionButton(imageSystemName: "pencil", action: onEditSelect)
            #endif
            editActionButton(imageSystemName: "trash.fill", action: onDeleteSelect)
            #if os(iOS)
                .padding(.top, -12)
            #endif
        }
        .padding(.bottom, -12)
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

    private func onDeleteSelect() {
        deletionConfirmation = true
    }

    private func handleDefiniteDeletion() {
        onDeleteTranslation()
        deletionConfirmation = false
    }
}

// #Preview {
//    PhraseView(phrase: PreviewData.phrases[0])
//        .modelContainer(for: [AppPhrase.self, AppTranslation.self], inMemory: true)
// }
