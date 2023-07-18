//
//  TranslationAPI.swift
//
//
//  Created by Kamaal M Farah on 17/07/2023.
//

import Foundation
import AppLocales

public struct PocketSlateTranslationAPI {
    private let client: Client
    let apiKey: String

    init(client: Client, apiKey: String) {
        self.client = client
        self.apiKey = apiKey
    }

    public func makeTranslation(forText text: String, from sourceLocale: Locale,
                                to targetLocale: Locale) async -> Result<String, PocketSlateAPIErrors> {
        let sourceLocaleIdentifier = String(sourceLocale.identifier.prefix(2))
        let targetLocaleIdentifer = String(targetLocale.identifier.prefix(2))
        let result: Operations.makeTranslation.Output
        do {
            result = try await client.makeTranslation(.init(
                headers: .init(App_Version: defaultHeaders.appVersion,
                               App_Name: defaultHeaders.appName,
                               Api_Key: defaultHeaders.apiKey),
                body: .json(.init(
                    source_locale: sourceLocaleIdentifier,
                    target_locale: targetLocaleIdentifer,
                    text: text
                ))
            ))
        } catch {
            return .failure(.unknownError(statusCode: 500, message: nil, context: error))
        }

        return parseMakeTranslation(result)
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

    private func parseMakeTranslation(_ response: Operations.makeTranslation
        .Output) -> Result<String, PocketSlateAPIErrors> {
        switch response {
        case let .ok(okResponse):
            switch okResponse.body {
            case let .json(jsonResponse):
                guard let translatedText = jsonResponse.translated_text else {
                    return .failure(.unknownError(
                        statusCode: 404,
                        message: AppLocales.getText(.NO_TRANSLATION_FOUND),
                        context: nil
                    ))
                }
                return .success(translatedText)
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
