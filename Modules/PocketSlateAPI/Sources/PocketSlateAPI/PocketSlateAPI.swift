//
//  PocketSlateAPI.swift
//
//
//  Created by Kamaal M Farah on 15/07/2023.
//

import Foundation
import OpenAPIRuntime
import KamaalExtensions
import OpenAPIURLSession

public struct PocketSlateAPI {
    public let health: PocketSlateHealthAPI
    public let translation: PocketSlateTranslationAPI

    public init(apiKey: String, apiURL: URL) {
        let client = Client(
            serverURL: apiURL,
            transport: URLSessionTransport()
        )
        self.health = .init(client: client)
        self.translation = .init(client: client, apiKey: apiKey)
    }
}
