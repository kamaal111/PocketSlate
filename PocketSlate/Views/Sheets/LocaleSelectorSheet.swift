//
//  LocaleSelectorSheet.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 29/05/2023.
//

import SwiftUI
import KamaalUI
import AppLocales

struct LocaleSelectorSheet: View {
    let onClose: () -> Void

    var body: some View {
        KSheetStack(
            title: AppLocales.getText(.LANGUAGES),
            leadingNavigationButton: { leadingNavigationButton },
            trailingNavigationButton: { Text.empty() }
        ) {
            VStack {
                Text("Sheet")
            }
            .padding(.vertical, .small)
        }
        .frame(minWidth: 200, minHeight: 200)
    }

    private var leadingNavigationButton: some View {
        Button(action: onClose) {
            Text(localized: .CLOSE)
                .foregroundColor(.accentColor)
                .bold()
        }
    }
}

struct LocaleSelectorSheet_Previews: PreviewProvider {
    static var previews: some View {
        LocaleSelectorSheet(onClose: { })
    }
}
