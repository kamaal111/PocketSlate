//
//  AppLocales.swift
//
//
//  Created by Kamaal Farah on 28/05/2023.
//

import Foundation

public struct AppLocales {
    private init() { }

    /// Depending on the key returns a localized string.
    /// - Parameters:
    ///   - key: the key to get the localized string.
    ///   - variables: variable to inject in to string.
    /// - Returns: a localized string.
    public static func getText(_ key: Keys, with variables: [CVarArg] = []) -> String {
        key.localized(with: variables)
    }
}

extension AppLocales.Keys {
    /// Localize ``AppLocales/AppLocales/Keys``.
    public var localized: String {
        localized(with: [])
    }

    /// Localize ``AppLocales/AppLocales/Keys`` with a injected variable.
    /// - Parameter variables: variable to inject in to string.
    /// - Returns: Returns a localized string.
    public func localized(with variables: [CVarArg]) -> String {
        let bundle = Bundle.module
        switch variables {
        case _ where variables.isEmpty:
            return NSLocalizedString(rawValue, bundle: bundle, comment: "")
        case _ where variables.count == 1:
            return String(format: NSLocalizedString(rawValue, bundle: bundle, comment: ""), variables[0])
        default:
            #if DEBUG
            fatalError("Amount of variables is not supported")
            #else
            return NSLocalizedString(rawValue, bundle: bundle, comment: "")
            #endif
        }
    }
}
