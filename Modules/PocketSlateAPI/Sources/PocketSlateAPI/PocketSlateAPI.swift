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

    public init() {
        let client = Client(
            serverURL: URL(staticString: "http://localhost:8000/api/v1"),
            transport: URLSessionTransport()
        )
        self.health = .init(client: client)
    }
}
