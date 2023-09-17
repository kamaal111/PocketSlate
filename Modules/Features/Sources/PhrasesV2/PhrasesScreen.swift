//
//  PhrasesScreen.swift
//
//
//  Created by Kamaal M Farah on 16/09/2023.
//

import Users
import AppUI
import SwiftUI
import KamaalUI
import KamaalExtensions

public struct PhrasesScreen: View {
    @EnvironmentObject private var userData: UserData
    @Environment(PhrasesManager.self) var phrasesManager

    @State private var viewModel = ViewModel()

    public init() { }

    public var body: some View {
        VStack {
            LocaleSelectors(
                locales: viewModel.locales,
                selectedLocaleSelector: .primary,
                swapLocales: { viewModel.swapLocales() },
                selectLocaleSelector: { localeSelector in viewModel.selectLocaleSelector(localeSelector) }
            )
            KScrollableForm {
                KSection(header: NSLocalizedString("New translation", bundle: .module, comment: "")) {
                    NewPhrasePanel(
                        primaryPhrase: $viewModel.newPrimaryPhrase,
                        secondaryPhrase: $viewModel.newSecondaryPhrase,
                        locales: viewModel.locales,
                        submitNewPhrase: { submitNewPhrase() }
                    )
                }
                #if os(macOS)
                .padding(.horizontal, .small)
                #endif
                if phrasesManager.isLoadingPhrase {
                    KLoading()
                }
                ForEach(phrasesManager.phrases) { phrase in
                    Text(phrase.translations?.first?.value ?? "Nothing")
                }
            }
        }
        .sheet(isPresented: $viewModel.localeSelectorSheetIsShown) {
            LocaleSelectorSheet(
                locales: viewModel.selectedLocaleSelectorLocales,
                supportedTranslatableLocales: viewModel.supportedTranslatableLocales,
                onClose: { viewModel.closeLocaleSelectorSheet() },
                onLocaleSelect: { locale in viewModel.selectLocale(locale) }
            )
        }
        .toolbar(content: {
            EditButton()
        })
        .environment(\.editMode, $viewModel.editMode)
        .onAppear(perform: handleOnAppear)
    }

    private func submitNewPhrase() {
        guard !viewModel.newPhrasePair.array.allSatisfy({ $0 == nil }) else { return }

        Task {
            #warning("Handle this error")
            await phrasesManager.createPhrase(values: viewModel.newPhrasePair, locales: viewModel.locales)
        }
    }

    private func handleOnAppear() {
        Task { await phrasesManager.fetchPhrasesForLocalePair(viewModel.locales) }
        Task {
            #warning("Handle this error")
            await viewModel.fetchSupportedTranslationLocales(forTargetLocale: userData.appLocale)
        }
    }
}

#if DEBUG
#Preview {
    PhrasesScreen()
        .usersEnvironment()
}
#endif
