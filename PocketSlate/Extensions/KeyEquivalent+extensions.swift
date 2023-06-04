//
//  KeyEquivalent+extensions.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 04/06/2023.
//

import SwiftUI

extension KeyEquivalent: Equatable {
    public static func == (lhs: KeyEquivalent, rhs: KeyEquivalent) -> Bool {
        lhs.character == rhs.character
    }
}

extension KeyEquivalent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(character)
    }
}
