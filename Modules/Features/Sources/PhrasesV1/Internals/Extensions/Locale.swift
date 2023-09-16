//
//  Locale.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 28/05/2023.
//

import Foundation

extension Locale {
    var identifierComponents: (primary: String.SubSequence, sub: String.SubSequence?) {
        let components = self.identifier.split(separator: "_")
        guard components.count > 1 else { return (components[0], nil) }

        return (components[0], components[1])
    }
}

extension Locale: Comparable {
    public static func < (lhs: Locale, rhs: Locale) -> Bool {
        lhs.identifier < rhs.identifier
    }
}
