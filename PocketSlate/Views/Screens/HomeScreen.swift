//
//  HomeScreen.swift
//  PocketSlate
//
//  Created by Kamaal Farah on 28/05/2023.
//

import SwiftUI

struct HomeScreen: View {
    @State private var searchText = ""

    var body: some View {
        ScrollView {
            TextField("Search", text: $searchText)
                .padding(.horizontal, .medium)
            ForEach(searchedText, id: \.self) { language in
                Text(language)
            }
        }
    }

    private var searchedText: [String] {
        let searchText = searchText.replacingOccurrences(of: " ", with: "")
        if searchText.isEmpty {
            return UserData.locales
                .map { makeMessage(fromLocale: $0) }
        }

        return UserData.locales
            .map { makeMessage(fromLocale: $0) }
            .filter { $0
                .replacingOccurrences(of: " ", with: "")
                .fuzzyMatch(searchText)
            }
    }

    private func makeMessage(fromLocale locale: Locale) -> String {
        let identifier = locale.identifier
        return "\(identifier) - \(locale.localizedString(forIdentifier: identifier)!)"
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
