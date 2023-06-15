//
//  Backend.swift
//
//
//  Created by Kamaal Farah on 28/05/2023.
//

import Foundation

public class Backend {
    private init(preview _: Bool) { }

    public static let shared = Backend(preview: false)

    public static let preview = Backend(preview: true)
}
