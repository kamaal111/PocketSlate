//
//  AppSizes.swift
//  PocketSlate
//
//  Created by Kamaal Farah on 28/05/2023.
//

import SwiftUI

public enum AppSizes: CGFloat {
    /// Size of 0
    case nada = 0
    /// Size of 2
    case extraExtraSmall = 2
    /// Size of 4
    case extraSmall = 4
    /// Size of 8
    case small = 8
    /// Size of 16
    case medium = 16
    /// Size of 24
    case large = 24
    /// Size of 32
    case extraLarge = 32
}

extension View {
    public func padding(_ edges: Edge.Set = .all, _ length: AppSizes) -> some View {
        padding(edges, length.rawValue)
    }

    public func cornerRadius(_ length: AppSizes) -> some View {
        cornerRadius(length.rawValue)
    }
}
