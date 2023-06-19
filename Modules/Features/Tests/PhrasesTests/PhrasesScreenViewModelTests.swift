//
//  PhrasesScreenViewModelTests.swift
//
//
//  Created by Kamaal M Farah on 17/06/2023.
//

import XCTest
import Foundation
@testable import Phrases

final class PhrasesScreenViewModelTests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var viewModel: PhrasesScreen.ViewModel!

    override func setUp() async throws {
        viewModel = PhrasesScreen.ViewModel(
            primaryLocale: Locale(identifier: "en"),
            secondaryLocale: Locale(identifier: "it")
        )
    }

    // - MARK: deselectTextEditingPhrase

    func testDeselectTextEditingPhraseAfterEditing() async {
        await setEditModeToEditing()
        let phrase1 = AppPhrase(
            id: UUID(uuidString: "e480ad03-3874-408f-9dff-3dc92bb2f0c5")!,
            translations: [
                Locale(identifier: "en"): ["Cheers"],
                Locale(identifier: "it"): ["Salute"],
            ]
        )
        let phrase2 = AppPhrase(
            id: UUID(uuidString: "36f6ab5f-5d2a-4107-846a-702697ed771f")!,
            translations: [
                Locale(identifier: "en"): ["Do you speak English"],
                Locale(identifier: "it"): ["Parla Inglese"],
            ]
        )

        await selectTextEditingPhrase(phrase: phrase1)
        viewModel.editingPrimaryPhraseField = "Cheers!"
        viewModel.editingSecondaryPhraseField = "Salute!"
        await selectTextEditingPhrase(phrase: phrase2)
        viewModel.editingPrimaryPhraseField = "Do you speak English?"
        viewModel.editingSecondaryPhraseField = "Parla Inglese?"
        await deselectTextEditingPhrase()

        XCTAssertEqual(viewModel.editedPhrases, [
            AppPhrase(
                id: phrase1.id,
                translations: [
                    Locale(identifier: "en"): ["Cheers!"],
                    Locale(identifier: "it"): ["Salute!"],
                ]
            ),
            AppPhrase(
                id: phrase2.id,
                translations: [
                    Locale(identifier: "en"): ["Do you speak English?"],
                    Locale(identifier: "it"): ["Parla Inglese?"],
                ]
            ),
        ])
    }

    // - MARK: selectTextEditingPhrase

    func testSelectTextEditingPhraseAfterEditingButNotChangingAnythingTheSecondTime() async {
        await setEditModeToEditing()
        let phrase1 = AppPhrase(
            id: UUID(uuidString: "eb0b4785-5892-49df-aaf7-eccaff099a36")!,
            translations: [
                Locale(identifier: "en"): ["Your welcome"],
                Locale(identifier: "it"): ["Prgo"],
            ]
        )
        let phrase2 = AppPhrase(
            id: UUID(uuidString: "91b0a57c-d9ec-49e5-9d86-3d9eefbf5338")!,
            translations: [
                Locale(identifier: "en"): ["Excuse me"],
                Locale(identifier: "it"): ["Mi scusi"],
            ]
        )

        await selectTextEditingPhrase(phrase: phrase1)
        viewModel.editingPrimaryPhraseField = "You're welcome"
        viewModel.editingSecondaryPhraseField = "Prego"
        await selectTextEditingPhrase(phrase: phrase2)
        await selectTextEditingPhrase(phrase: phrase1)
        viewModel.editingPrimaryPhraseField = "You're welcome"
        viewModel.editingSecondaryPhraseField = "Prego"
        await selectTextEditingPhrase(phrase: phrase2)

        XCTAssertEqual(viewModel.editingPrimaryPhraseField, "Excuse me")
        XCTAssertEqual(viewModel.editingSecondaryPhraseField, "Mi scusi")
        XCTAssertEqual(viewModel.editedPhrases, [
            AppPhrase(
                id: phrase1.id,
                translations: [
                    Locale(identifier: "en"): ["You're welcome"],
                    Locale(identifier: "it"): ["Prego"],
                ]
            ),
        ])
    }

    func testSelectTextEditingPhraseAfterEditingAndThenReplaceExistingEditedPhrase() async throws {
        await setEditModeToEditing()
        let phrase1 = AppPhrase(
            id: UUID(uuidString: "ac5e046c-f866-4a7d-b49a-91a8a10dcfab")!,
            translations: [
                Locale(identifier: "en"): ["N"],
                Locale(identifier: "it"): ["o"],
            ]
        )
        let phrase2 = AppPhrase(
            id: UUID(uuidString: "bbe31172-2bb7-41e9-a865-ee61906c2bf3")!,
            translations: [
                Locale(identifier: "en"): ["I am sorry"],
                Locale(identifier: "it"): ["Mi dispiace"],
            ]
        )

        await selectTextEditingPhrase(phrase: phrase1)
        viewModel.editingPrimaryPhraseField = "No"
        viewModel.editingSecondaryPhraseField = "No"
        await selectTextEditingPhrase(phrase: phrase2)
        await selectTextEditingPhrase(phrase: phrase1)
        viewModel.editingPrimaryPhraseField = "Yes"
        viewModel.editingSecondaryPhraseField = "Si"
        await selectTextEditingPhrase(phrase: phrase2)

        XCTAssertEqual(viewModel.editingPrimaryPhraseField, "I am sorry")
        XCTAssertEqual(viewModel.editingSecondaryPhraseField, "Mi dispiace")
        XCTAssertEqual(viewModel.editedPhrases, [
            AppPhrase(
                id: phrase1.id,
                translations: [
                    Locale(identifier: "en"): ["Yes"],
                    Locale(identifier: "it"): ["Si"],
                ]
            ),
        ])
    }

    func testSelectTextEditingPhraseAfterEditingAndThenSwappingLocales() async throws {
        await setEditModeToEditing()
        let phrase1 = AppPhrase(
            id: UUID(uuidString: "a6fe9924-8dd5-4cd1-8602-a125fe1448c1")!,
            translations: [
                Locale(identifier: "en"): ["Good veefening"],
                Locale(identifier: "it"): ["Buona pera"],
            ]
        )
        let phrase2 = AppPhrase(
            id: UUID(uuidString: "128dd843-6b05-4669-b1b1-d6551732d4f3")!,
            translations: [
                Locale(identifier: "en"): ["Speak slowly"],
                Locale(identifier: "it"): ["Parla lentamente"],
            ]
        )

        await selectTextEditingPhrase(phrase: phrase1)
        viewModel.editingSecondaryPhraseField = "Good evening"
        viewModel.editingPrimaryPhraseField = "Buona sera"
        await swapLocales()
        await selectTextEditingPhrase(phrase: phrase2)

        XCTAssertEqual(viewModel.primaryLocale, Locale(identifier: "it"))
        XCTAssertEqual(viewModel.editingPrimaryPhraseField, "Parla lentamente")
        XCTAssertEqual(viewModel.secondaryLocale, Locale(identifier: "en"))
        XCTAssertEqual(viewModel.editingSecondaryPhraseField, "Speak slowly")
        XCTAssertEqual(viewModel.editedPhrases, [
            AppPhrase(
                id: phrase1.id,
                translations: [
                    Locale(identifier: "en"): ["Good evening"],
                    Locale(identifier: "it"): ["Buona sera"],
                ]
            ),
        ])
    }

    func testSelectTextEditingPhraseAfterEditingAndThenSwitchingPhrases() async throws {
        await setEditModeToEditing()
        let phrase1 = AppPhrase(
            id: UUID(uuidString: "15cd8073-94fa-444a-a5a4-98b9612fda45")!,
            translations: [
                Locale(identifier: "en"): ["Thank u"],
                Locale(identifier: "it"): ["Graze"],
            ]
        )
        let phrase2 = AppPhrase(
            id: UUID(uuidString: "075f4818-3ab6-42ec-a2a4-8d8adf7300cf")!,
            translations: [
                Locale(identifier: "en"): ["Very good"],
                Locale(identifier: "it"): ["Molto bene"],
            ]
        )

        await selectTextEditingPhrase(phrase: phrase1)
        viewModel.editingPrimaryPhraseField = "Thank You"
        viewModel.editingSecondaryPhraseField = "Grazie"
        await selectTextEditingPhrase(phrase: phrase2)

        XCTAssertEqual(viewModel.editingPrimaryPhraseField, "Very good")
        XCTAssertEqual(viewModel.editingSecondaryPhraseField, "Molto bene")
        XCTAssertEqual(viewModel.editedPhrases, [
            AppPhrase(
                id: phrase1.id,
                translations: [
                    Locale(identifier: "en"): ["Thank You"],
                    Locale(identifier: "it"): ["Grazie"],
                ]
            ),
        ])
    }

    func testSelectTextEditingPhrase() async throws {
        await setEditModeToEditing()
        let phrase = AppPhrase(
            id: UUID(uuidString: "9b1749f4-5eb7-429f-97c3-284750543918")!,
            translations: [
                Locale(identifier: "en"): ["Hello"],
                Locale(identifier: "it"): ["Ciao"],
            ]
        )

        await selectTextEditingPhrase(phrase: phrase)

        XCTAssertEqual(viewModel.editingPrimaryPhraseField, "Hello")
        XCTAssertEqual(viewModel.editingSecondaryPhraseField, "Ciao")
        XCTAssert(viewModel.editedPhrases.isEmpty)
    }

    // - MARK: Utils

    private func deselectTextEditingPhrase() async {
        guard viewModel.textEditingPhrase != nil else { return }

        let expectation = XCTestExpectation(description: "Deselects locales")
        let cancellable = viewModel.$textEditingPhrase
            .sink(receiveValue: { value in
                guard value == nil else { return }
                expectation.fulfill()
            })

        await viewModel.deselectTextEditingPhrase()

        await fulfillment(of: [expectation], timeout: 3)
        XCTAssertNil(viewModel.textEditingPhrase)
    }

    private func swapLocales() async {
        let expectation = XCTestExpectation(description: "Swaps locales")
        let previousPrimaryLocale = viewModel.primaryLocale
        let previousSecondaryLocale = viewModel.secondaryLocale
        let cancellable = viewModel.$primaryLocale
            .sink(receiveValue: { value in
                guard value != previousPrimaryLocale else { return }

                expectation.fulfill()
            })

        await viewModel.swapLocales()

        await fulfillment(of: [expectation], timeout: 3)
        XCTAssertEqual(viewModel.primaryLocale, previousSecondaryLocale)
        XCTAssertEqual(viewModel.secondaryLocale, previousPrimaryLocale)
        XCTAssertNotEqual(viewModel.primaryLocale, viewModel.secondaryLocale)
        XCTAssertNotEqual(previousPrimaryLocale, previousSecondaryLocale)
    }

    private func setEditModeToEditing() async {
        let expectation = XCTestExpectation(description: "Sets edit mode")
        let cancellable = viewModel.$editedPhrases
            .sink(receiveValue: { _ in
                expectation.fulfill()
            })

        viewModel.editMode = .active

        await fulfillment(of: [expectation], timeout: 3)
        XCTAssert(viewModel.editedPhrases.isEmpty)
    }

    private func selectTextEditingPhrase(phrase: AppPhrase) async {
        let expectation = XCTestExpectation(description: "Selects a phrase")
        let cancellable = viewModel.$textEditingPhrase
            .sink(receiveValue: { value in
                guard value == phrase else { return }

                expectation.fulfill()
            })

        await viewModel.selectTextEditingPhrase(phrase)

        await fulfillment(of: [expectation], timeout: 3)
        XCTAssertEqual(viewModel.textEditingPhrase?.id, phrase.id)
        XCTAssert(viewModel.phraseTextIsBeingEdited(phrase))
    }
}
