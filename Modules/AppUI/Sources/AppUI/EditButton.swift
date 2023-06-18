//
//  EditButton.swift
//
//
//  Created by Kamaal M Farah on 17/06/2023.
//

#if os(macOS)
import SwiftUI
import AppLocales

public struct EditButton: View {
    @Environment(\.editMode) var editMode

    public init() { }

    public var body: some View {
        Button(action: handleAction) {
            Text(localized: buttonText)
                .bold()
                .foregroundColor(.accentColor)
        }
    }

    private var buttonText: AppLocales.Keys {
        guard let editMode else {
            assertionFailure("No environment set")
            return .EDIT
        }

        return editMode.isEditing ? .DONE : .EDIT
    }

    private func handleAction() {
        guard let editMode else {
            assertionFailure("No environment set")
            return
        }

        withAnimation { editMode.wrappedValue.toggle() }
    }
}

struct EditButton_Previews: PreviewProvider {
    static var previews: some View {
        EditButton()
    }
}
#endif
