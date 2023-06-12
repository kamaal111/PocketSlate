//
//  Text.swift
//
//
//  Created by Kamaal M Farah on 12/06/2023.
//

import SwiftUI

@available(macOS 10.15, iOS 13, *)
extension Text {
    public init(localized key: AppLocales.Keys, with variables: [CVarArg] = []) {
        self.init(AppLocales.getText(key, with: variables))
    }
}
