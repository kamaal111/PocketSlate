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

    public init() {
        let client = Client(
            serverURL: URL(staticString: "http://localhost:8000/api/v1"),
            transport: URLSessionTransport()
        )
        self.health = .init(client: client)
        self.translation = .init(client: client)
    }
}

public struct PocketSlateTranslationAPI {
    private let client: Client

    init(client: Client) {
        self.client = client
    }

    public func getSupportedLocales() async throws {
        let result = try await client.getSupportedLocales(.init(headers: .init(
            App_Version: "1.0.0",
            App_Name: "pocket-slate",
            Api_Key: "xxx"
        )))
        print("result", result)
    }
}
