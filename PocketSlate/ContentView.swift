//
//  ContentView.swift
//  PocketSlate
//
//  Created by Kamaal Farah on 28/05/2023.
//

import SwiftUI
import Navigation
import PocketSlateAPI

struct ContentView: View {
    var body: some View {
        AppNavigationView()
            .onAppear(perform: {
                Task {
                    try! await healthPing()
                }
            })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
