//
//  CacheUtils.swift
//
//
//  Created by Kamaal M Farah on 21/07/2023.
//

import Foundation
import KamaalLogger

private let logger = KamaalLogger(from: CacheUtils.self, failOnError: true)

public enum CacheUtils {
    public static func cacheResult<Success: Codable, Failure: Error>(
        cachingKey: String,
        expirationDate: Date,
        completion: () async -> Result<Success, Failure>
    ) async -> Result<Success, Failure> {
        if let cachedObject: Success = getCache(cachingKey: cachingKey) {
            return .success(cachedObject)
        }

        let result = await completion()
        let success: Success
        switch result {
        case let .success(successResult):
            success = successResult
        case .failure:
            return result
        }

        setCache(cachingKey: cachingKey, value: .init(response: success, expirationDate: expirationDate))
        return result
    }

    static func cacheResult<Success: Codable, Failure: Error>(
        cachingKey: String,
        expirationDate: Date,
        completion: () -> Result<Success, Failure>
    ) -> Result<Success, Failure> {
        if let cachedObject: Success = getCache(cachingKey: cachingKey) {
            return .success(cachedObject)
        }

        let result = completion()
        let success: Success
        switch result {
        case let .success(successResult):
            success = successResult
        case .failure:
            return result
        }

        setCache(cachingKey: cachingKey, value: .init(response: success, expirationDate: expirationDate))
        return result
    }

    private static func getCache<T: Codable>(cachingKey: String) -> T? {
        guard let cachedData = UserDefaults.standard.data(forKey: cachingKey) else { return nil }

        let decodedCache: CacheContainer<T>
        do {
            decodedCache = try JSONDecoder().decode(CacheContainer<T>.self, from: cachedData)
        } catch {
            logger.error(label: "Failed to decode cache object of \(cachingKey)", error: error)
            return nil
        }

        if decodedCache.hasExpired {
            logger.info("Cached object of \(cachingKey) expired")
            return nil
        }

        logger.info("Loaded cache object of \(cachingKey)")
        return decodedCache.response
    }

    private static func setCache(cachingKey: String, value: CacheContainer<some Codable>) {
        let encodedCache: Data
        do {
            encodedCache = try JSONEncoder().encode(value)
        } catch {
            logger.error(label: "Failed to encode cache object of \(cachingKey)", error: error)
            return
        }

        logger.info("Storing cached object of \(cachingKey)")
        UserDefaults.standard.setValue(encodedCache, forKey: cachingKey)
    }
}

struct CacheContainer<T: Codable>: Codable {
    let response: T
    let expirationDate: Date

    var hasExpired: Bool {
        expirationDate < Date()
    }
}
