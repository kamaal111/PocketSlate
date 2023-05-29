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

    var id: UUID {
        switch self {
        case .phrases:
            return UUID(uuidString: "1aad48ae-a16d-44e4-adb6-49b4b972be36")!
        case .settings:
            return UUID(uuidString: "3a96090d-ac94-4c37-8eb9-7e707a62a7c9")!
        }
    }

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
