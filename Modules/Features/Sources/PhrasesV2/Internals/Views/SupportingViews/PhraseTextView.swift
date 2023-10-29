//
//  PhraseTextView.swift
//
//
//  Created by Kamaal M Farah on 18/09/2023.
//

import Users
import SwiftUI
import KamaalUI
import PSShared
import KamaalExtensions

struct PhraseTextView: View {
    @Environment(\.editMode) private var editMode
    @Environment(\.isEnabled) private var isEnabled

    @EnvironmentObject private var userData: UserData

    @Binding var editingText: String

    let translation: String
    let locale: Locale
    let isTranslatable: Bool
    let isEditingText: Bool
    let translateText: () -> Void
    let onEditSelect: () -> Void

    var body: some View {
        KJustStack {
            if isEditing, isEditingText {
                editableText
            } else {
                displayText
            }
        }
        .ktakeWidthEagerly(alignment: .leading)
        #if os(iOS)
            .onTapGesture(perform: {
                if isEditing {
                    onEditSelect()
                }
            })
        #endif
    }

    private var editableText: some View {
        HStack {
            KFloatingTextField(
                text: $editingText,
                title: userData.appLocale.localizedString(forIdentifier: locale.identifier)!
            )
        }
    }

    private var displayText: some View {
        HStack {
            if translationIsNotEmpty, isTranslatable {
                Image(systemName: "globe")
                    .kBold()
                    .foregroundColor(.accentColor)
                    .onTapGesture { translateText() }
            }
            if translationIsNotEmpty {
                Text(translation)
                Spacer()
                Image(systemName: "speaker.wave.3")
                    .kBold()
                    .foregroundColor(isEnabled ? .accentColor : .secondary)
                    .onTapGesture { speakOut() }
            } else {
                Text("Not set", bundle: .module)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var isEditing: Bool {
        editMode?.isEditing == true
    }

    private var translationIsNotEmpty: Bool {
        !translation.trimmingByWhitespacesAndNewLines.isEmpty
    }

    private func speakOut() {
        Task { await AsyncSynthesizer.speak(string: translation, locale: locale) }
    }
}

#Preview {
    VStack {
        PhraseTextView(
            editingText: .constant("Hello"),
            translation: "Hello",
            locale: Locale(identifier: "en"),
            isTranslatable: true,
            isEditingText: true,
            translateText: { },
            onEditSelect: { }
        )
        PhraseTextView(
            editingText: .constant("Ciao"),
            translation: "Ciao",
            locale: Locale(identifier: "it"),
            isTranslatable: false,
            isEditingText: true,
            translateText: { },
            onEditSelect: { }
        )
    }
}
