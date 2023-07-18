//
//  HealthAPI.swift
//
//
//  Created by Kamaal M Farah on 16/07/2023.
//

import Foundation

public struct PocketSlateHealthAPI {
    private let client: Client

    init(client: Client) {
        self.client = client
    }

    public func ping() async -> Result<String, PocketSlateAPIErrors> {
        let result: Operations.healthPing.Output
        do {
            result = try await client.healthPing(.init())
        } catch {
            return .failure(.unknownError(statusCode: 500, message: nil, context: error))
        }

        switch result {
        case let .ok(response):
            switch response.body {
            case let .json(jsonResponse):
                return .success(jsonResponse.message!)
            }
        case let .undocumented(statusCode: statusCode, _):
            return .failure(PocketSlateAPIErrors.unknownError(statusCode: statusCode, message: nil, context: nil))
        }
    }
}
