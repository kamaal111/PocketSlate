//
//  AppLogoColorFormRow.swift
//  Playground
//
//  Created by Kamaal M Farah on 22/07/2023.
//

import SwiftUI

struct AppLogoColorFormRow<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            Divider()
            content
        }
    }
}

#Preview {
    AppLogoColorFormRow(title: "Title") {
        Text("Yes")
    }
}
