//
//  CacheContainer.swift
//
//
//  Created by Kamaal M Farah on 19/07/2023.
//

import Foundation

struct CacheContainer<T: Codable>: Codable {
    let response: T
    let expirationDate: Date

    var hasExpired: Bool {
        expirationDate < Date()
    }
}
