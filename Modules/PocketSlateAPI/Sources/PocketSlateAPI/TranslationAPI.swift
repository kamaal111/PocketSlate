//
//  TranslationAPI.swift
//
//
//  Created by Kamaal M Farah on 17/07/2023.
//

import PSShared
import Foundation
import AppLocales
import KamaalLogger

private let logger = KamaalLogger(from: PocketSlateTranslationAPI.self, failOnError: true)

public struct PocketSlateTranslationAPI {
    private let client: Client
    let apiKey: String

    init(client: Client, apiKey: String) {
        self.client = client
        self.apiKey = apiKey
    }

    public func makeTranslation(forText text: String,
                                from sourceLocale: Locale,
                                to targetLocale: Locale) async -> Result<String, PocketSlateAPIErrors> {
        let sourceLocaleIdentifier = String(sourceLocale.identifier.split(separator: "-")[0])
        let targetLocaleIdentifer = String(targetLocale.identifier.split(separator: "-")[0])

        return await CacheUtils.cacheResult(
            cachingKey: "make_translation_text_\(text)_from_\(sourceLocaleIdentifier)_to_\(targetLocaleIdentifer)",
            expirationDate: Date().adding(minutes: 60 * 24 * 7), // 10_080 minutes == 1 week
            completion: {
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
                    logger.error(label: "Failed to make translations", error: error)
                    return .failure(.unknownError(statusCode: 500, message: nil, context: error))
                }

                return parseMakeTranslation(result)
                    .map { success in
                        logger.info("Successfully got translated text")
                        return success
                    }
                    .mapError { error in
                        logger.error(label: "Failed to get translated text", error: error)
                        return error
                    }
            }
        )
    }

    public func getSupportedLocales(as target: Locale) async -> Result<[SupportedLocale], PocketSlateAPIErrors> {
        let targetIdentifier = String(target.identifier.split(separator: "-")[0])

        return await CacheUtils.cacheResult(
            cachingKey: "get_supported_locales_as_\(targetIdentifier)",
            expirationDate: Date().adding(minutes: 60 * 24 * 7), // 10_080 minutes == 1 week
            completion: {
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
                    logger.error(label: "Failed to get supported locales", error: error)
                    return .failure(.unknownError(statusCode: 500, message: nil, context: error))
                }

                return parseGetsupportedLocalesResponse(result)
                    .map { success in
                        logger.info("Successfully got supported locales")
                        return success
                    }
                    .mapError { error in
                        logger.error(label: "Failed to get supported locales", error: error)
                        return error
                    }
            }
        )
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
        self.appName = "pocket-slate"

        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        else { fatalError("Failed to typecast") }
        self.appVersion = appVersion
    }
}
