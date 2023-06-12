//
//  LocaleSelectorSheet.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 29/05/2023.
//

import Users
import SwiftUI
import KamaalUI
import AppLocales
import KamaalLogger
import KamaalAlgorithms
import KamaalExtensions

private let shortcuts: [KeyboardShortcutEvents: KeyboardShortcutConfiguration] = [
    .downArrow: .init(id: UUID(uuidString: "b1227523-fa31-4aa5-be4f-c8dfad11d2df")!, key: .downArrow),
    .upArrow: .init(id: UUID(uuidString: "1c63cd93-9bbd-43a9-bf59-89bfbaeaead7")!, key: .upArrow),
    .return: .init(id: UUID(uuidString: "d969527a-bd58-49d9-ae43-92db3fd63b13")!, key: .return),
].merged(with: (1 ..< 10).reduce([:]) { result, number in
    let shortcut = KeyboardShortcutConfiguration(
        id: UUID(),
        key: KeyEquivalent("\(number)".first!),
        modifiers: .command
    )
    return result.merged(with: [.number(value: number): shortcut])
})

private let logger = KamaalLogger(from: LocaleSelectorSheet.self)

struct LocaleSelectorSheet: View {
    @EnvironmentObject private var userData: UserData

    @State private var searchTerm = ""
    @State private var highlightedItem = 0

    let locales: [Locale]
    let onClose: () -> Void
    let onLocaleSelect: (_ locale: Locale) -> Void

    var body: some View {
        KeyboardShortcutView(shortcuts: shortcuts.values.asArray(), onEmit: handleKeyboardShortcut) {
            KSheetStack(
                title: AppLocales.getText(.LANGUAGES),
                leadingNavigationButton: { leadingNavigationButton },
                trailingNavigationButton: { Text.empty() }
            ) {
                VStack {
                    KFloatingTextField(text: $searchTerm, title: AppLocales.getText(.SEARCH))
                    ScrollView {
                        ForEach(numberedFilteredLocales) { numberedLocale in
                            localeButton(numberedLocale)
                        }
                        if filteredLocales.isEmpty {
                            Text(localized: .NO_LOCALE_SEARCH_MATCH, with: [searchTerm])
                            clearSearchButton
                        }
                    }
                    .ktakeWidthEagerly()
                }
                .padding(.vertical, .medium)
            }
            .backgroundColor(light: .secondaryBackground.light, dark: .secondaryBackground.dark)
            .onChange(of: searchTerm, perform: onSearchTermChange)
            #if os(macOS)
                .frame(minWidth: 300, minHeight: 200, maxHeight: 400)
            #endif
        }
    }

    private var leadingNavigationButton: some View {
        Button(action: onClose) {
            Text(localized: .CLOSE)
                .foregroundColor(.accentColor)
                .bold()
        }
    }

    private var clearSearchButton: some View {
        Button(action: clearSearchTerm) {
            HStack(spacing: 0) {
                Text(localized: .CLEAR_SEARCH)
                    .bold()
                    .padding(.trailing, .extraExtraSmall)
                Image(systemName: "eraser.fill")
                    .kBold()
            }
            .foregroundColor(.accentColor)
        }
        .buttonStyle(.plain)
    }

    private func localeButton(_ numberedLocale: NumberedLocale) -> some View {
        let button = Button(action: { onLocaleSelect(numberedLocale.locale) }) {
            HStack {
                Text(numberedLocale.message(appLocale: userData.appLocale))
                    .foregroundColor(.accentColor)
                    .bold()
                    .ktakeWidthEagerly(alignment: .leading)
                if numberedLocale.number < 9 {
                    Spacer()
                    Text("􀆔\(numberedLocale.number + 1)")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, .extraExtraSmall)
            .padding(.horizontal, .small)
            .ktakeWidthEagerly()
            .backgroundColor(light: .secondaryItemBackground.light, dark: .secondaryItemBackground.dark)
            .cornerRadius(.extraSmall)
        }
        .buttonStyle(.plain)

        return KJustStack {
            if highlightedItem == numberedLocale.number {
                button
                    .padding(.all, .extraExtraSmall)
                    .overlay(RoundedRectangle(cornerRadius: AppSizes.small.rawValue)
                        .inset(by: 2)
                        .stroke(Color.accentColor.opacity(0.5), lineWidth: 2)
                        .clipped())
            } else {
                button
            }
        }
    }

    private var numberedFilteredLocales: [NumberedLocale] {
        filteredLocales
            .enumerated()
            .map { NumberedLocale(locale: $0.element, number: $0.offset) }
    }

    private var filteredLocales: [Locale] {
        let searchTerm = searchTerm.replacingOccurrences(of: " ", with: "")
        guard !searchTerm.isEmpty else { return locales }

        return locales
            .filter {
                let identifier = $0.identifier
                return identifier.fuzzyMatch(searchTerm) || userData.appLocale
                    .localizedString(forIdentifier: identifier)!
                    .replacingOccurrences(of: " ", with: "")
                    .fuzzyMatch(searchTerm)
            }
    }

    private func handleKeyboardShortcut(_ shortcut: KeyboardShortcutConfiguration) {
        guard let event = shortcuts.find(by: \.value.id, is: shortcut.id)?.key else {
            logger.error("Failed to find shortcut event")
            return
        }

        switch event {
        case .downArrow:
            if (highlightedItem + 1) < filteredLocales.count {
                highlightedItem += 1
            }
        case .upArrow:
            if highlightedItem != 0 {
                highlightedItem -= 1
            }
        case .return:
            if !filteredLocales.isEmpty {
                onLocaleSelect(filteredLocales[highlightedItem])
                clearSearchTerm()
            }
        case let .number(value):
            assert([1, 2, 3, 4, 5, 6, 7, 8, 9].contains(value))
            let isInBound = (1 ..< 10).contains(value)
            assert(isInBound)
            if isInBound {
                onLocaleSelect(filteredLocales[value - 1])
                clearSearchTerm()
            }
        }
    }

    private func onSearchTermChange(_: String) {
        if highlightedItem != 0 {
            withAnimation { highlightedItem = 0 }
        }
    }

    private func clearSearchTerm() {
        searchTerm = ""
    }
}

private enum KeyboardShortcutEvents: Hashable {
    case downArrow
    case upArrow
    case `return`
    case number(value: Int)
}

private struct NumberedLocale: Hashable, Identifiable {
    let locale: Locale
    let number: Int

    var id: String { locale.identifier }

    func message(appLocale: Locale) -> String {
        "\(locale.identifier) - \(appLocale.localizedString(forIdentifier: locale.identifier)!)"
    }
}

struct LocaleSelectorSheet_Previews: PreviewProvider {
    static var previews: some View {
        LocaleSelectorSheet(locales: PhrasesScreen.ViewModel.locales, onClose: { }, onLocaleSelect: { _ in })
            .usersEnvironment()
    }
}
