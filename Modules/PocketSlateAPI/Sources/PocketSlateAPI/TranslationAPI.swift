//
//  TranslationAPI.swift
//
//
//  Created by Kamaal M Farah on 17/07/2023.
//

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
        let sourceLocaleIdentifier = String(sourceLocale.identifier.prefix(2))
        let targetLocaleIdentifer = String(targetLocale.identifier.prefix(2))

        return await withCache(
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
                    return .failure(.unknownError(statusCode: 500, message: nil, context: error))
                }

                return parseMakeTranslation(result)
            }
        )
    }

    public func getSupportedLocales(as target: Locale) async -> Result<[SupportedLocale], PocketSlateAPIErrors> {
        let targetIdentifier = String(target.identifier.prefix(2))

        return await withCache(
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
                    return .failure(.unknownError(statusCode: 500, message: nil, context: error))
                }

                return parseGetsupportedLocalesResponse(result)
            }
        )
    }

    private var defaultHeaders: TranslationAPIHeaders {
        .init(apiKey: apiKey)
    }

    private func withCache<Success: Codable, Failure: Error>(
        cachingKey: String,
        expirationDate: Date,
        completion: () async -> Result<Success, Failure>
    ) async -> Result<Success, Failure> {
        let cachedData = UserDefaults.standard.data(forKey: cachingKey)
        if let cachedData {
            let decodedCache = try? JSONDecoder().decode(CacheContainer<Success>.self, from: cachedData)
            assert(decodedCache != nil)
            if let decodedCache, !decodedCache.hasExpired {
                logger.info("Returning cached result for \(cachingKey)")
                return .success(decodedCache.response)
            }
        }

        let result = await completion()
        let success: Success
        switch result {
        case let .success(successResult):
            success = successResult
        case .failure:
            return result
        }

        let containedCache = CacheContainer(response: success, expirationDate: expirationDate)
        let encodedContainedCache = try? JSONEncoder().encode(containedCache)
        assert(encodedContainedCache != nil)
        guard let encodedContainedCache else {
            logger.error("Failed to encode cache of \(cachingKey)")
            return result
        }

        logger.info("Storing cache result of \(cachingKey)")
        UserDefaults.standard.setValue(encodedContainedCache, forKey: cachingKey)

        return result
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
