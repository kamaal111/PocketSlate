//
//  AppLogoColorSelector.swift
//  Playground
//
//  Created by Kamaal M Farah on 22/07/2023.
//

import SwiftUI

struct AppLogoColorSelector: View {
    @Binding var color: Color

    let title: String

    private let circleSize: CGFloat = 20

    var body: some View {
        AppLogoColorFormRow(title: title) {
            HStack {
                ForEach(PLAYGROUND_SELECTABLE_COLORS, id: \.self) { color in
                    Button(action: { withAnimation { self.color = color } }) {
                        ZStack {
                            if color == self.color {
                                Circle()
                                    .frame(width: circleSize * 1.2, height: circleSize * 1.2)
                                    .foregroundColor(.accentColor)
                            }
                            Circle()
                                .frame(width: circleSize, height: circleSize)
                                .foregroundColor(color)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    AppLogoColorSelector(color: .constant(.red), title: "Title")
}
