//
//  NewPhrasePanel.swift
//
//
//  Created by Kamaal M Farah on 16/09/2023.
//

import AppUI
import Users
import SwiftUI
import KamaalUI
import KamaalExtensions

struct NewPhrasePanel: View {
    @EnvironmentObject private var userData: UserData

    @Binding var primaryPhrase: String
    @Binding var secondaryPhrase: String

    let locales: (primary: Locale, secondary: Locale)
    let submitNewPhrase: () -> Void

    var body: some View {
        HStack {
            KFloatingTextField(
                text: $primaryPhrase,
                title: userData.appLocale.localizedString(forIdentifier: locales.primary.identifier)!
            )
            .onSubmit(submitNewPhrase)
            #if os(iOS)
            SplitterView()
            #endif
            KFloatingTextField(
                text: $secondaryPhrase,
                title: userData.appLocale.localizedString(forIdentifier: locales.secondary.identifier)!
            )
            .onSubmit(submitNewPhrase)
            #if os(macOS)
            Button(action: submitNewPhrase) {
                Text(NSLocalizedString("Done", bundle: .module, comment: ""))
                    .foregroundColor(submitButtonIsDisabled ? .secondary : .accentColor)
            }
            .disabled(submitButtonIsDisabled)
            .padding(.top, 12)
            #else
            if !submitButtonIsDisabled {
                SplitterView()
                Button(action: submitNewPhrase) {
                    Text(NSLocalizedString("Done", bundle: .module, comment: ""))
                        .foregroundColor(submitButtonIsDisabled ? .secondary : .accentColor)
                }
            }
            #endif
        }
    }

    private var submitButtonIsDisabled: Bool {
        primaryPhrase.trimmingByWhitespacesAndNewLines.isEmpty
            && secondaryPhrase.trimmingByWhitespacesAndNewLines.isEmpty
    }
}

#if DEBUG
#Preview {
    NewPhrasePanel(
        primaryPhrase: .constant("Hello"),
        secondaryPhrase: .constant("Ciao"),
        locales: (Locale(identifier: "en"), Locale(identifier: "it")),
        submitNewPhrase: { }
    )
    .usersEnvironment()
}
#endif
