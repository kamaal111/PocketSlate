//
//  PhrasesScreen.swift
//
//
//  Created by Kamaal M Farah on 11/06/2023.
//

import Users
import SwiftUI
import KamaalUI
import AppLocales
import KamaalPopUp

public struct PhrasesScreen: View {
    @Environment(\.colorScheme) private var colorScheme

    @EnvironmentObject private var userData: UserData
    @EnvironmentObject private var phrasesManager: PhrasesManager
    @EnvironmentObject private var popUpManager: KPopUpManager

    @StateObject private var viewModel = ViewModel()

    public init() { }

    public var body: some View {
        VStack {
            LocaleSelectors(
                primaryLocale: viewModel.primaryLocale,
                secondaryLocale: viewModel.secondaryLocale,
                selectedLocaleSelector: viewModel.selectedLocaleSelector,
                swapLocales: { viewModel.swapLocales() },
                selectLocaleSelector: { viewModel.selectLocaleSelector($0) }
            )
            KScrollableForm {
                NewPhrasePanel(
                    primaryPhrase: $viewModel.primaryNewPhraseField,
                    secondaryPhrase: $viewModel.secondaryNewPhraseField,
                    primaryLocale: viewModel.primaryLocale,
                    secondaryLocale: viewModel.secondaryLocale,
                    submitButtonIsDisabled: viewModel.newPhraseSubmitButtonIsDisabled,
                    submitNewPhrase: submitNewPhrase
                )
                .padding(.horizontal, .small)
                ForEach(phrasesManager.phrases) { phrase in
                    PhraseView(
                        phrase: phrase,
                        primaryLocale: viewModel.primaryLocale,
                        secondaryLocale: viewModel.secondaryLocale
                    )
                }
            }
        }
        .sheet(isPresented: $viewModel.localeSelectorSheetIsShown) {
            LocaleSelectorSheet(
                locales: viewModel.selectedLocaleSelectorLocales,
                onClose: { viewModel.closeLocaleSelectorSheet() },
                onLocaleSelect: { locale in viewModel.selectLocale(locale) }
            )
        }
        .onChange(of: viewModel.primaryLocale, perform: onPrimaryLocaleChange)
        .onChange(of: viewModel.secondaryLocale, perform: onSecondaryLocaleChange)
        .onAppear(perform: handleOnAppear)
    }

    private func handleOnAppear() {
        phrasesManager.fetchPhrasesForLocalePair(primary: viewModel.primaryLocale, secondary: viewModel.secondaryLocale)
    }

    private func onPrimaryLocaleChange(_ newValue: Locale) {
        phrasesManager.fetchPhrasesForLocalePair(primary: newValue, secondary: viewModel.secondaryLocale)
    }

    private func onSecondaryLocaleChange(_ newValue: Locale) {
        phrasesManager.fetchPhrasesForLocalePair(primary: viewModel.primaryLocale, secondary: newValue)
    }

    private func submitNewPhrase() {
        guard !viewModel.newPhraseSubmitButtonIsDisabled else { return }

        let result = phrasesManager.createPhrase(
            primaryTranslation: viewModel.primaryNewPhraseField,
            primaryLocale: viewModel.primaryLocale,
            secondaryTranslation: viewModel.secondaryNewPhraseField,
            secondaryLocale: viewModel.secondaryLocale
        )
        switch result {
        case let .failure(failure):
            switch failure {
            case .creationFailure:
                popUpManager.showPopUp(style: .bottom(
                    title: AppLocales.getText(.PHRASE_CREATION_FAILURE_TITLE),
                    type: .error,
                    description: AppLocales.getText(.PHRASE_CREATION_FAILURE_DESCRIPTION)
                ), timeout: 3)
            }
        case .success:
            break
        }

        viewModel.clearNewPhraseFields()
    }
}

struct PhrasesScreen_Previews: PreviewProvider {
    static var previews: some View {
        PhrasesScreen()
            .usersEnvironment()
    }
}
