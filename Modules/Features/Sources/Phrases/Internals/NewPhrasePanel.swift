//
//  NewPhrasePanel.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 11/06/2023.
//

import Users
import SwiftUI
import KamaalUI
import AppLocales

struct NewPhrasePanel: View {
    @EnvironmentObject private var userData: UserData

    @Binding var primaryPhrase: String
    @Binding var secondaryPhrase: String

    let primaryLocale: Locale
    let secondaryLocale: Locale
    let submitButtonIsDisabled: Bool
    let submitNewPhrase: () -> Void

    var body: some View {
        HStack {
            KFloatingTextField(
                text: $primaryPhrase,
                title: userData.appLocale.localizedString(forIdentifier: primaryLocale.identifier)!
            )
            .onSubmit(submitNewPhrase)
            KFloatingTextField(
                text: $secondaryPhrase,
                title: userData.appLocale.localizedString(forIdentifier: secondaryLocale.identifier)!
            )
            .onSubmit(submitNewPhrase)
            Button(action: submitNewPhrase) {
                Text(localized: .DONE)
                    .foregroundColor(submitButtonIsDisabled ? .secondary : .accentColor)
            }
            .disabled(submitButtonIsDisabled)
            .padding(.top, 12)
        }
    }
}

struct NewPhrasePanel_Previews: PreviewProvider {
    static var previews: some View {
        NewPhrasePanel(
            primaryPhrase: .constant("Hello"),
            secondaryPhrase: .constant("Ciao"),
            primaryLocale: Locale(identifier: "en"),
            secondaryLocale: Locale(identifier: "it"),
            submitButtonIsDisabled: false,
            submitNewPhrase: { }
        )
    }
}
