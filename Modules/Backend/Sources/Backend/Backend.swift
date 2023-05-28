//
//  Backend.swift
//
//
//  Created by Kamaal Farah on 28/05/2023.
//

import CDPersist
import Foundation

public class Backend {
    public let itemClient: DataClient<CoreItem>

    private init(preview: Bool) {
        self.itemClient = .init(context: preview ? .preview : .shared)
    }

    public static let shared = Backend(preview: false)

    public static let preview = Backend(preview: true)
}
