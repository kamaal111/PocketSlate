//
//  KeyboardShortcutView.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 04/06/2023.
//

import SwiftUI

struct KeyboardShortcutView<Content: View>: View {
    let shortcuts: [KeyboardShortcutConfiguration]
    let content: Content
    let onEmit: (_ shortcut: KeyboardShortcutConfiguration) -> Void

    init(
        shortcuts: [KeyboardShortcutConfiguration],
        onEmit: @escaping (_ shortcut: KeyboardShortcutConfiguration) -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.shortcuts = shortcuts
        self.content = content()
        self.onEmit = onEmit
    }

    var body: some View {
        ZStack {
            ForEach(shortcuts) { shortcut in
                Button(action: { onEmit(shortcut) }) { EmptyView() }
                    .keyboardShortcut(shortcut.key, modifiers: shortcut.modifiers)
                    .buttonStyle(.borderless)
            }
            content
        }
    }
}

struct KeyboardShortcutConfiguration: Hashable, Identifiable {
    let id: UUID
    let key: KeyEquivalent
    let modifiers: EventModifiers

    init(id: UUID, key: KeyEquivalent, modifiers: EventModifiers = []) {
        self.id = id
        self.key = key
        self.modifiers = modifiers
    }
}

struct KeyboardShortcutView_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardShortcutView(shortcuts: [], onEmit: { _ in }, content: {
            Text("Content")
        })
    }
}
