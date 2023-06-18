//
//  SplitterView.swift
//
//
//  Created by Kamaal M Farah on 18/06/2023.
//

import SwiftUI

public struct SplitterView: View {
    public init() { }

    public var body: some View {
        Capsule()
            .foregroundColor(.secondary)
            .frame(width: 1)
            .padding(.vertical, .extraSmall)
    }
}

struct SplitterView_Previews: PreviewProvider {
    static var previews: some View {
        SplitterView()
    }
}
