//
//  LocaleListItemButton.swift
//
//
//  Created by Kamaal M Farah on 17/09/2023.
//

import Users
import AppUI
import SwiftUI
import KamaalUI

struct LocaleListItemButton: View {
    @EnvironmentObject private var userData: UserData

    let numberedLocale: NumberedLocale
    let isTranslatable: Bool
    let isHighlighted: Bool
    let action: (_ locale: Locale) -> Void

    var body: some View {
        if isHighlighted {
            button
                .padding(.all, .extraExtraSmall)
                .overlay(RoundedRectangle(cornerRadius: AppSizes.small.rawValue)
                    .inset(by: 2)
                    .stroke(Color.accentColor.opacity(0.5), lineWidth: 2)
                    .clipped())
        } else {
            button
        }
    }

    private var button: some View {
        Button(action: { action(numberedLocale.locale) }) {
            HStack {
                Image(systemName: "globe")
                    .kBold()
                    .foregroundColor(isTranslatable ? .accentColor : .secondary)
                Text(numberedLocale.message(appLocale: userData.appLocale))
                    .foregroundColor(.accentColor)
                    .bold()
                    .ktakeWidthEagerly(alignment: .leading)
                #if os(macOS)
                if numberedLocale.number < 9 {
                    Spacer()
                    Text("􀆔\(numberedLocale.number + 1)")
                        .foregroundColor(.secondary)
                }
                #endif
            }
            .padding(.vertical, .extraExtraSmall)
            .padding(.horizontal, .small)
            .ktakeWidthEagerly()
            .backgroundColor(light: .secondaryItemBackground.light, dark: .secondaryItemBackground.dark)
            .cornerRadius(.extraSmall)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LocaleListItemButton(
        numberedLocale: .init(locale: PreviewData.locales.first!, number: 0),
        isTranslatable: true,
        isHighlighted: true,
        action: { _ in }
    )
    .usersEnvironment()
}
