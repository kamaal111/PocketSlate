//
//  PhrasesScreen.swift
//
//
//  Created by Kamaal M Farah on 11/06/2023.
//

import Users
import AppUI
import SwiftUI
import KamaalUI
import AppLocales
import KamaalPopUp
import KamaalLogger

private let logger = KamaalLogger(from: PhrasesScreen.self, failOnError: true)

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
                KSection(header: AppLocales.getText(.NEW_TRANSLATION)) {
                    NewPhrasePanel(
                        primaryPhrase: $viewModel.primaryNewPhraseField,
                        secondaryPhrase: $viewModel.secondaryNewPhraseField,
                        primaryLocale: viewModel.primaryLocale,
                        secondaryLocale: viewModel.secondaryLocale,
                        submitButtonIsDisabled: viewModel.newPhraseSubmitButtonIsDisabled,
                        submitNewPhrase: submitNewPhrase
                    )
                }
                #if os(macOS)
                .padding(.horizontal, .small)
                #endif
                if !phrases.isEmpty {
                    KSection(header: AppLocales.getText(.TRANSLATIONS)) {
                        ForEach(phrases) { phrase in
                            PhraseView(
                                editingPrimaryField: $viewModel.editingPrimaryPhraseField,
                                editingSecondaryField: $viewModel.editingSecondaryPhraseField,
                                phrase: phrase,
                                primaryLocale: viewModel.primaryLocale,
                                secondaryLocale: viewModel.secondaryLocale,
                                isEditingText: viewModel.phraseTextIsBeingEdited(phrase),
                                onEditText: { phrase in viewModel.selectTextEditingPhrase(phrase) },
                                onDeleteTranslation: { phrase in phrasesManager.deleteTranslation(
                                    phrase: phrase,
                                    primary: viewModel.primaryLocale,
                                    secondary: viewModel.secondaryLocale
                                ) }
                            )
                            #if os(iOS)
                            .onSubmit { viewModel.deselectTextEditingPhrase() }
                            #endif
                        }
                    }
                    #if os(macOS)
                    .padding(.horizontal, .small)
                    #endif
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
        .toolbar(content: {
            EditButton()
        })
        .environment(\.editMode, $viewModel.editMode)
        .onChange(of: viewModel.primaryLocale, perform: onPrimaryLocaleChange)
        .onChange(of: viewModel.secondaryLocale, perform: onSecondaryLocaleChange)
        .onChange(of: viewModel.editedPhrases, perform: onEditedPhrasesChange)
        .onChange(of: viewModel.editMode, perform: onEditModeChange)
        .onAppear(perform: handleOnAppear)
    }

    private var phrases: [AppPhrase] {
        if viewModel.editMode.isEditing {
            return phrasesManager.phrases
                .map { phrase in
                    viewModel.editedPhrases.find(by: \.id, is: phrase.id) ?? phrase
                }
        } else {
            return phrasesManager.phrases
        }
    }

    private func handleOnAppear() {
        phrasesManager.fetchPhrasesForLocalePair(primary: viewModel.primaryLocale, secondary: viewModel.secondaryLocale)
    }

    private func onEditModeChange(_ newValue: EditMode) {
        guard !newValue.isEditing else { return }
        guard !viewModel.editedPhrases.isEmpty else { return }
        guard viewModel.textEditingPhrase == nil else { return }

        logger.debug("Updating phrases")
        phrasesManager.updatePhrases(editedPhrases: viewModel.editedPhrases)
    }

    private func onEditedPhrasesChange(_ newValue: [AppPhrase]) {
        guard !viewModel.editMode.isEditing else { return }
        guard !newValue.isEmpty else { return }
        guard viewModel.textEditingPhrase != nil else { return }

        logger.debug("Updating phrases")
        phrasesManager.updatePhrases(editedPhrases: newValue)
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
