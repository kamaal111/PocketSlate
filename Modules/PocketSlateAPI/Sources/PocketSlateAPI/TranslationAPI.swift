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

    public func getSupportedLocales(as target: Locale) async -> Result<[SupportedLocale], PocketSlateAPIErrors> {
        let targetIdentifier = String(target.identifier.prefix(2))
        let result: Operations.getSupportedLocales.Output
        do {
            result = try await client.getSupportedLocales(.init(
                query: .init(target: targetIdentifier),
                headers: .init(
                    App_Version: defaultHeaders.appVersion,
                    App_Name: defaultHeaders.appName,
                    Api_Key: defaultHeaders.apiKey
                )
            ))
        } catch {
            return .failure(.unknownError(statusCode: 500, message: nil, context: error))
        }

        return parseGetsupportedLocalesResponse(result)
    }

    private var defaultHeaders: TranslationAPIHeaders {
        .init(apiKey: apiKey)
    }

    private func parseGetsupportedLocalesResponse(_ response: Operations.getSupportedLocales
        .Output) -> Result<[SupportedLocale], PocketSlateAPIErrors> {
        switch response {
        case let .ok(okResponse):
            switch okResponse.body {
            case let .json(jsonResponse):
                let supportedLocales = (jsonResponse.value as? [[String: String?]] ?? [])
                    .compactMap { locale -> SupportedLocale? in
                        guard let tag = locale["tag"], let tag else { return nil }
                        guard let name = locale["name"], let name else { return nil }

                        return SupportedLocale(name: name, tag: Locale(identifier: tag))
                    }
                return .success(supportedLocales)
            }
        case let .badRequest(error):
            switch error.body {
            case let .json(jsonResponse):
                return .failure(.badRequest(message: jsonResponse.message))
            }
        case let .forbidden(error):
            switch error.body {
            case let .json(jsonResponse):
                return .failure(.unauthorized(message: jsonResponse.message))
            }
        case let .unprocessableEntity(error):
            switch error.body {
            case let .json(jsonResponse):
                return .failure(.badRequest(message: jsonResponse.message))
            }
        case let .internalServerError(error):
            switch error.body {
            case let .json(jsonResponse):
                return .failure(.unknownError(statusCode: 500, message: jsonResponse.message, context: nil))
            }
        case let .undocumented(statusCode: statusCode, _):
            return .failure(.unknownError(statusCode: statusCode, message: nil, context: nil))
        }
    }
}

private struct TranslationAPIHeaders {
    let apiKey: String
    let appVersion: String
    let appName: String

    init(apiKey: String) {
        self.apiKey = apiKey
        self.appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        self.appName = "pocket-slate"
    }
}
