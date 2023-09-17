//
//  LocaleSelectorSheet.swift
//
//
//  Created by Kamaal M Farah on 16/09/2023.
//

import Users
import AppUI
import SwiftUI
import KamaalUI
import KamaalLogger
import KamaalAlgorithms
import KamaalExtensions

private let logger = KamaalLogger(from: LocaleSelectorSheet.self, failOnError: true)

private let shortcuts: [KeyboardShortcutEvents: KeyboardShortcutConfiguration] = [
    .downArrow: .init(key: .downArrow),
    .upArrow: .init(key: .upArrow),
    .return: .init(key: .return),
].merged(with: (1 ..< 10).reduce([:]) { result, number in
    let shortcut = KeyboardShortcutConfiguration(key: KeyEquivalent("\(number)".first!), modifiers: .command)
    return result.merged(with: [.number(value: number): shortcut])
})

struct LocaleSelectorSheet: View {
    @EnvironmentObject private var userData: UserData

    @State private var highlightedItem = 0
    @State private var searchTerm = ""

    let locales: [Locale]
    let supportedTranslatableLocales: [Locale]
    let onClose: () -> Void
    let onLocaleSelect: (_ locale: Locale) -> Void

    var body: some View {
        KeyboardShortcutView(shortcuts: shortcuts.values.asArray(), onEmit: handleKeyboardShortcut) {
            KSheetStack(
                title: NSLocalizedString("Languages", bundle: .module, comment: ""),
                leadingNavigationButton: { leadingNavigationButton },
                trailingNavigationButton: { Text.empty() }
            ) {
                VStack {
                    KFloatingTextField(
                        text: $searchTerm,
                        title: NSLocalizedString("Search", bundle: .module, comment: "")
                    )
                    ScrollView {
                        ForEach(numberedFilteredLocales) { numberedLocale in
                            LocaleListItemButton(
                                numberedLocale: numberedLocale,
                                isTranslatable: supportedTranslatableLocales.contains(numberedLocale.locale),
                                isHighlighted: highlightedItem == numberedLocale.number,
                                action: { locale in onLocaleSelect(locale) }
                            )
                        }
                        if filteredLocales.isEmpty {
                            Text(String(
                                format: NSLocalizedString("Nothing found matching '%@'", bundle: .module, comment: ""),
                                searchTerm
                            ))
                            clearSearchButton
                        }
                    }
                    .ktakeSizeEagerly()
                }
                .padding(.vertical, .medium)
            }
            .backgroundColor(light: .secondaryBackground.light, dark: .secondaryBackground.dark)
            .onChange(of: searchTerm, onSearchTermChange)
            #if os(macOS)
                .frame(minWidth: 300, minHeight: 200, maxHeight: 400)
            #endif
        }
    }

    private var leadingNavigationButton: some View {
        Button(action: onClose) {
            Text("Close", bundle: .module)
                .foregroundColor(.accentColor)
                .bold()
        }
    }

    private var clearSearchButton: some View {
        Button(action: clearSearchTerm) {
            HStack(spacing: 0) {
                Text("Clear search", bundle: .module)
                    .bold()
                    .padding(.trailing, .extraExtraSmall)
                Image(systemName: "eraser.fill")
                    .kBold()
            }
            .foregroundColor(.accentColor)
        }
        .buttonStyle(.plain)
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

    private func onSearchTermChange(_: String, _: String) {
        guard highlightedItem != 0 else { return }

        withAnimation { highlightedItem = 0 }
    }

    private func clearSearchTerm() {
        searchTerm = ""
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
            let isInBound = (1 ..< 10).contains(value)
            assert(isInBound)
            if isInBound {
                onLocaleSelect(filteredLocales[value - 1])
                clearSearchTerm()
            }
        }
    }
}

private enum KeyboardShortcutEvents: Hashable {
    case downArrow
    case upArrow
    case `return`
    case number(value: Int)
}

#Preview {
    LocaleSelectorSheet(
        locales: PreviewData.locales,
        supportedTranslatableLocales: PreviewData.locales.removed(at: 1),
        onClose: { },
        onLocaleSelect: { _ in }
    )
    .usersEnvironment()
}
