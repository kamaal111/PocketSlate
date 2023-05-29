//
//  PhrasesScreen.swift
//  PocketSlate
//
//  Created by Kamaal Farah on 28/05/2023.
//

import SwiftUI
import KamaalUI

struct PhrasesScreen: View {
    @Environment(\.colorScheme) private var colorScheme

    @EnvironmentObject private var userData: UserData

    var body: some View {
        VStack {
            ZStack {
                HStack {
                    LocaleSelector(currentLocale: UserData.locales[300], locales: UserData.locales)
                    LocaleSelector(currentLocale: UserData.locales[1], locales: UserData.locales)
                }
            }
            .padding(.vertical, .small)
            .background(colorScheme == .dark ? Color.black : Color.gray.opacity(0.1))
            .ktakeWidthEagerly()
            Spacer()
                .ktakeSizeEagerly()
        }
    }
}

struct PhrasesScreen_Previews: PreviewProvider {
    static var previews: some View {
        PhrasesScreen()
            .environmentObject(UserData())
    }
}
