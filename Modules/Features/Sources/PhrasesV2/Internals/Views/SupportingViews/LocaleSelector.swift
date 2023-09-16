//
//  LocaleSelector.swift
//
//
//  Created by Kamaal M Farah on 16/09/2023.
//

import Users
import AppUI
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
                                .lineLimit(1)
                        }
                    }
                    .kBindToFrameSize($textSize)
                    SplitterView()
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
        "\(currentLocale.identifier) - \(userData.appLocale.localizedString(forIdentifier: currentLocale.identifier)!)"
    }

    private var localeSubIdentifier: String? {
        guard let subIdentifier = currentLocale.identifierComponents.sub else { return nil }

        return String(subIdentifier)
    }
}

#if DEBUG
#Preview {
    HStack {
        LocaleSelector(currentLocale: PreviewData.locales.last!, isSelected: true, action: { })
        LocaleSelector(currentLocale: PreviewData.locales.first!, isSelected: false, action: { })
    }
    .padding(.vertical, .large)
    .previewLayout(.sizeThatFits)
    .usersEnvironment()
}
#endif
