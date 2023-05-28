//
//  Item.swift
//
//
//  Created by Kamaal Farah on 28/05/2023.
//

import Foundation

public struct Item: Identifiable, Hashable {
    public let id: UUID

    public init(id: UUID) {
        self.id = id
    }
}
