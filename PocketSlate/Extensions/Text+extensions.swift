//
//  Text+extensions.swift
//  PocketSlate
//
//  Created by Kamaal Farah on 28/05/2023.
//

import SwiftUI
import AppLocales

extension Text {
    init(localized key: AppLocales.Keys, with variables: [CVarArg] = []) {
        self.init(AppLocales.getText(key, with: variables))
    }

    static func empty() -> Text {
        Text("")
    }
}
