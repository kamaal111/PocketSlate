//
//  PhrasesEnvironmentModifier.swift
//
//
//  Created by Kamaal M Farah on 12/06/2023.
//

import SwiftUI

extension View {
    public func phrasesEnvironment() -> some View {
        modifier(PhrasesEnvironmentModifier())
    }
}

private struct PhrasesEnvironmentModifier: ViewModifier {
    @StateObject private var phrasesManager = PhrasesManager()

    func body(content: Content) -> some View {
        content
            .environmentObject(phrasesManager)
    }
}
