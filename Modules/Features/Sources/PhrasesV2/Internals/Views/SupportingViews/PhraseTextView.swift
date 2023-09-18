//
//  PhraseTextView.swift
//
//
//  Created by Kamaal M Farah on 18/09/2023.
//

import SwiftUI
import KamaalUI
import PSShared
import KamaalExtensions

struct PhraseTextView: View {
    @Environment(\.isEnabled) var isEnabled

    let translation: String?
    let sourceLocale: Locale
    let targetLocale: Locale
    let isTranslatable: Bool
    let translateText: () -> Void

    var body: some View {
        KJustStack {
            HStack {
                if translationIsNotEmpty, isTranslatable {
                    Image(systemName: "globe")
                        .kBold()
                        .foregroundColor(.accentColor)
                        .onTapGesture { translateText() }
                }
                if translationIsNotEmpty {
                    Text(translation!)
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
        .ktakeWidthEagerly(alignment: .leading)
        #if os(iOS)
            .onTapGesture(perform: {
                if editMode?.isEditing == true {
                    onEditText(phrase)
                }
            })
        #endif
    }

    private var translationIsNotEmpty: Bool {
        translation?.trimmingByWhitespacesAndNewLines.isEmpty == false
    }

    private func speakOut() {
        Task { await AsyncSynthesizer.speak(string: translation!, locale: sourceLocale) }
    }
}

#Preview {
    VStack {
        PhraseTextView(
            translation: "Hello",
            sourceLocale: Locale(identifier: "en"),
            targetLocale: Locale(identifier: "it"),
            isTranslatable: true,
            translateText: { }
        )
        PhraseTextView(
            translation: "Ciao",
            sourceLocale: Locale(identifier: "it"),
            targetLocale: Locale(identifier: "en"),
            isTranslatable: false,
            translateText: { }
        )
    }
}
