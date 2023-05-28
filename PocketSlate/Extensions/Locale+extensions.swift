//
//  Locale+extensions.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 28/05/2023.
//

import Foundation

extension Locale: Comparable {
    public static func < (lhs: Locale, rhs: Locale) -> Bool {
        lhs.identifier < rhs.identifier
    }
}
