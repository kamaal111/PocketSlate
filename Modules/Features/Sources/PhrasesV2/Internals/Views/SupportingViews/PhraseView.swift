//
//  PhraseView.swift
//
//
//  Created by Kamaal M Farah on 18/09/2023.
//

import SwiftUI
import SwiftData
import Persistance

struct PhraseView: View {
    let phrase: AppPhrase

    var body: some View {
        Text("Hello, World!")
    }
}

// #Preview {
//    PhraseView(phrase: PreviewData.phrases[0])
//        .modelContainer(for: [AppPhrase.self, AppTranslation.self], inMemory: true)
// }
