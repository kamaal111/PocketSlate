//
//  TranslationAPI.swift
//
//
//  Created by Kamaal M Farah on 17/07/2023.
//

import Foundation

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
