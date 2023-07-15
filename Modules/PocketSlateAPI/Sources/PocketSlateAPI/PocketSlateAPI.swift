//
//  PocketSlateAPI.swift
//
//
//  Created by Kamaal M Farah on 15/07/2023.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

public func healthPing() async throws {
    let client = Client(
        serverURL: URL(string: "http://localhost:8000/api/v1")!,
        transport: URLSessionTransport()
    )
    let response = try await client.healthPing(.init())
    print(response)
}
