//
//  SupportedLocale.swift
//
//
//  Created by Kamaal M Farah on 18/07/2023.
//

import Foundation

public struct SupportedLocale: Hashable, Codable {
    public let name: String
    public let tag: Locale

    public init(name: String, tag: Locale) {
        self.name = name
        self.tag = tag
    }
}
