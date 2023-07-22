//
//  AppLogo.swift
//  Playground
//
//  Created by Kamaal M Farah on 22/07/2023.
//

import SwiftUI

struct AppLogo: View {
    let size: CGFloat
    let backgroundColor: Color
    let curvedCornersSize: CGFloat

    var body: some View {
        ZStack {
            backgroundColor
        }
        .frame(width: size, height: size)
        .cornerRadius(curvedCornersSize)
    }
}

#Preview {
    AppLogo(size: 150, backgroundColor: .red, curvedCornersSize: 16)
}
