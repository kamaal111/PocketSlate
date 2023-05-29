//
//  LocaleSelector.swift
//  PocketSlate
//
//  Created by Kamaal M Farah on 29/05/2023.
//

import SwiftUI
import KamaalUI

struct LocaleSelector: View {
    @Environment(\.colorScheme) private var colorScheme

    @EnvironmentObject private var userData: UserData

    @State private var textSize: CGSize = .zero
    @State private var selected = false

    let currentLocale: Locale
    let locales: [Locale]

    var body: some View {
        Button(action: {
            print("currentLocale", currentLocale)
            withAnimation { selected.toggle() }
        }) {
            ZStack {
                backgroundColor
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
                        .rotationEffect(selected ? Angle(degrees: 180) : Angle(degrees: 0))
                        .padding(.trailing, .small)
                }
            }
            .cornerRadius(.small)
        }
        .buttonStyle(.plain)
        .frame(maxHeight: textSize.height + AppSizes.medium.rawValue)
        .padding(.horizontal, .small)
    }

    private var backgroundColor: Color {
        if colorScheme == .dark {
            return .white.opacity(0.2)
        }

        return .white
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
            LocaleSelector(currentLocale: UserData.locales[300], locales: UserData.locales)
            LocaleSelector(currentLocale: UserData.locales[0], locales: UserData.locales)
        }
        .padding(.vertical, .large)
        .environmentObject(UserData())
        .previewLayout(.sizeThatFits)
    }
}
