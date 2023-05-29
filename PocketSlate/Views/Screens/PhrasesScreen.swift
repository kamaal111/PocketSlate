//
//  PhrasesScreen.swift
//  PocketSlate
//
//  Created by Kamaal Farah on 28/05/2023.
//

import SwiftUI
import KamaalUI
import KamaalAlgorithms

struct PhrasesScreen: View {
    @State private var searchText = ""

    var body: some View {
        KScrollableForm {
            ForEach(searchedText, id: \.self) { language in
                Text(language)
                    .ktakeWidthEagerly()
            }
        }
        .searchable(text: $searchText)
    }

    private var searchedText: [String] {
        let searchText = searchText.replacingOccurrences(of: " ", with: "")

        let formattedLocales = UserData.locales
            .map { makeMessage(fromLocale: $0) }

        if searchText.isEmpty {
            return formattedLocales
        }

        return formattedLocales
            .filter {
                $0
                    .replacingOccurrences(of: " ", with: "")
                    .fuzzyMatch(searchText)
            }
    }

    private func makeMessage(fromLocale locale: Locale) -> String {
        let identifier = locale.identifier
        return "\(identifier) - \(locale.localizedString(forIdentifier: identifier)!)"
    }
}

struct PhrasesScreen_Previews: PreviewProvider {
    static var previews: some View {
        PhrasesScreen()
    }
}
