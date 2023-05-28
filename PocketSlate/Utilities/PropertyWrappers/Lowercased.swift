//
//  Lowercased.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 29/05/2023.
//

import Foundation

@propertyWrapper
struct Lowercased {
    let wrappedValue: String

    init(wrappedValue: String) {
        self.wrappedValue = wrappedValue.lowercased()
    }
}
