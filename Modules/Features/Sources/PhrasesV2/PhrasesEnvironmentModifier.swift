//
//  PhrasesEnvironmentModifier.swift
//
//
//  Created by Kamaal M Farah on 16/09/2023.
//

import SwiftUI

extension View {
    public func phrasesEnvironment() -> some View {
        modifier(PhrasesEnvironmentModifier())
    }
}

private struct PhrasesEnvironmentModifier: ViewModifier {
    @State private var phrasesManager = PhrasesManager()

    func body(content: Content) -> some View {
        content
            .environment(phrasesManager)
    }
}
