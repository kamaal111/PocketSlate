//
//  Text+extensions.swift
//  PocketSlate
//
//  Created by Kamaal Farah on 28/05/2023.
//

import SwiftUI
import AppLocales

extension Text {
    init(localized key: AppLocales.Keys) {
        self.init(key.localized)
    }

    static func empty() -> Text {
        Text("")
    }
}
