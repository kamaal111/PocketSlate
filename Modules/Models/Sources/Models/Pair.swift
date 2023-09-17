//
//  Pair.swift
//
//
//  Created by Kamaal M Farah on 17/09/2023.
//

import Foundation

public struct Pair<T: Equatable>: Equatable {
    public let primary: T
    public let secondary: T

    public init(primary: T, secondary: T) {
        self.primary = primary
        self.secondary = secondary
    }

    public var array: [T] {
        [primary, secondary]
    }

    public func swapped() -> Pair {
        Pair(primary: secondary, secondary: primary)
    }

    public func setPrimary(with value: T) -> Pair {
        Pair(primary: value, secondary: secondary)
    }

    public func setSecondary(with value: T) -> Pair {
        Pair(primary: primary, secondary: value)
    }
}
