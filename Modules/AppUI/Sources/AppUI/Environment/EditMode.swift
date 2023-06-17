//
//  EditMode.swift
//
//
//  Created by Kamaal M Farah on 17/06/2023.
//

import SwiftUI

#if os(macOS)
public enum EditMode {
    case active
    case inactive

    public var isEditing: Bool {
        self == .active
    }

    public mutating func toggle() {
        self = toggled()
    }

    private func toggled() -> EditMode {
        isEditing ? .inactive : .active
    }
}

public struct EditModeKey: EnvironmentKey {
    public static let defaultValue: Binding<EditMode>? = nil
}

extension EnvironmentValues {
    public var editMode: Binding<EditMode>? {
        get { self[EditModeKey.self] }
        set { self[EditModeKey.self] = newValue }
    }
}
#endif

extension Binding<EditMode> {
    public var isEditing: Bool {
        wrappedValue.isEditing
    }
}
