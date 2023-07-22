//
//  AppLogo.swift
//  Playground
//
//  Created by Kamaal M Farah on 22/07/2023.
//

import SwiftUI
import KamaalUI
import KamaalExtensions

struct AppLogo: View {
    let size: CGFloat
    let backgroundColor: Color
    let translatedTextColor: Color
    let translatedTextBackgroundColor: Color
    let curvedCornersSize: CGFloat

    var body: some View {
        ZStack {
            backgroundColor
            VStack {
                ZStack {
                    translatedTextBackgroundColor
                    HStack {
                        Text("文")
                            .foregroundStyle(translatedTextColor)
                            .font(.system(size: size / 8, weight: .bold))
                        Text("K")
                            .foregroundStyle(translatedTextColor)
                            .font(.custom("Korean-Calligraphy", size: size / 6))
                    }
                }
                .frame(width: (size / 4) + (size / 10), height: size / 4)
                .cornerRadius(size / 16)
                .padding(.bottom, size / 1.5)
            }
            Image("Globe")
                .kSize(.squared(size / 1.5))
                .padding(.top, size / 12)
        }
        .frame(width: size, height: size)
        .cornerRadius(curvedCornersSize)
    }
}

#Preview {
    AppLogo(
        size: 150,
        backgroundColor: .white,
        translatedTextColor: .black,
        translatedTextBackgroundColor: Color("LogoBackgroundColor"),
        curvedCornersSize: 16
    )
    .padding(.all)
    .previewLayout(.sizeThatFits)
}
