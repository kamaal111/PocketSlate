//
//  AppNavigationView.swift
//
//
//  Created by Kamaal M Farah on 15/06/2023.
//

import SwiftUI
import KamaalNavigation

public struct AppNavigationView: View {
    public init() { }

    public var body: some View {
        NavigationStackView(
            stack: [Screens](),
            root: { screen in MainView(screen: screen) },
            subView: { screen in MainView(screen: screen, displayMode: .inline) },
            sidebar: { Sidebar() }
        )
    }
}

struct AppNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        AppNavigationView()
    }
}
