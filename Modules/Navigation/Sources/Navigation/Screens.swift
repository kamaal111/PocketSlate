//
//  Screens.swift
//  PocketSlate
//
//  Created by Kamaal Farah on 28/05/2023.
//

import AppLocales
import Foundation
import KamaalNavigation

enum Screens: Hashable, Codable, Identifiable, CaseIterable, NavigatorStackValue {
    case phrases
    case settings

    var id: Screens { self }

    var isTabItem: Bool {
        switch self {
        case .phrases, .settings:
            return true
        }
    }

    var isSidebarItem: Bool {
        switch self {
        case .phrases, .settings:
            return true
        }
    }

    var imageSystemName: String {
        switch self {
        case .phrases:
            return "text.book.closed.fill"
        case .settings:
            return "gearshape.fill"
        }
    }

    var title: String {
        switch self {
        case .phrases:
            return AppLocales.getText(.PHRASES)
        case .settings:
            return AppLocales.getText(.SETTINGS)
        }
    }

    static var root: Screens = .phrases
}
