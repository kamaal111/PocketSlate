//
//  LocaleSelector.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 29/05/2023.
//

import SwiftUI
import KamaalUI

struct LocaleSelector: View {
    @EnvironmentObject private var userData: UserData

    @State private var textSize: CGSize = .zero

    let currentLocale: Locale
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                HStack {
                    VStack {
                        Text(displayName)
                            .foregroundColor(.accentColor)
                            .ktakeWidthEagerly()
                        if let localeSubIdentifier {
                            Text(localeSubIdentifier)
                                .foregroundColor(.secondary)
                                .ktakeWidthEagerly()
                        } else {
                            Text("k")
                                .foregroundColor(.white.opacity(0.01))
                                .ktakeWidthEagerly()
                        }
                    }
                    .kBindToFrameSize($textSize)
                    Capsule()
                        .foregroundColor(.secondary)
                        .frame(width: 1)
                        .padding(.vertical, .extraSmall)
                    Image(systemName: "chevron.down")
                        .font(Font.headline.bold())
                        .foregroundColor(.accentColor)
                        .rotationEffect(isSelected ? Angle(degrees: 180) : Angle(degrees: 0))
                        .padding(.trailing, .small)
                }
            }
            .backgroundColor(light: .secondaryItemBackground.light, dark: .secondaryItemBackground.dark)
            .cornerRadius(.small)
        }
        .buttonStyle(.plain)
        .frame(maxHeight: textSize.height + AppSizes.medium.rawValue)
        .padding(.horizontal, .small)
    }

    private var displayName: String {
        userData.appLocale.localizedString(forIdentifier: String(currentLocale.identifierComponents.primary))!
    }

    private var localeSubIdentifier: String? {
        guard let subIdentifier = currentLocale.identifierComponents.sub else { return nil }

        return String(subIdentifier)
    }
}

struct LocaleSelector_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            LocaleSelector(currentLocale: PhrasesScreen.ViewModel.locales.last!, isSelected: true, action: { })
            LocaleSelector(currentLocale: PhrasesScreen.ViewModel.locales.first!, isSelected: false, action: { })
        }
        .padding(.vertical, .large)
        .environmentObject(UserData())
        .previewLayout(.sizeThatFits)
    }
}
