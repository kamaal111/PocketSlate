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

    public init(apiKey: String) {
        let client = Client(
            serverURL: URL(staticString: "http://localhost:8000/api/v1"),
            transport: URLSessionTransport()
        )
        self.health = .init(client: client)
        self.translation = .init(client: client, apiKey: apiKey)
    }
}

public struct PocketSlateTranslationAPI {
    private let client: Client
    let apiKey: String

    init(client: Client, apiKey: String) {
        self.client = client
        self.apiKey = apiKey
    }

    public func getSupportedLocales() async throws {
        let result = try await client.getSupportedLocales(.init(
            query: .init(target: "en"),
            headers: .init(App_Version: "1.0.0", App_Name: "pocket-slate", Api_Key: apiKey)
        ))
        print("result", result)
    }
}
