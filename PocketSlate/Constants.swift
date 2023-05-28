//
//  Constants.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 28/05/2023.
//

import Foundation

enum Constants {
    static let defaultLanguageCode = Locale(identifier: "en")
    static let priorityLanguages = [
        defaultLanguageCode,
        Locale(identifier: "zh"),
        Locale(identifier: "hi"),
        Locale(identifier: "es"),
        Locale(identifier: "fr"),
        Locale(identifier: "ar"),
        Locale(identifier: "bn"),
        Locale(identifier: "ru"),
        Locale(identifier: "pt"),
        Locale(identifier: "ur"),
        Locale(identifier: "id"),
        Locale(identifier: "de"),
        Locale(identifier: "ja"),
        Locale(identifier: "tr"),
        Locale(identifier: "yue"),
        Locale(identifier: "vi"),
        Locale(identifier: "ko"),
        Locale(identifier: "sw"),
        Locale(identifier: "it"),
    ]
}
