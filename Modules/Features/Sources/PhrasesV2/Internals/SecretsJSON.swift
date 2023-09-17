//
//  SecretsJSON.swift
//
//
//  Created by Kamaal M Farah on 17/09/2023.
//

import Foundation
import KamaalUtils
import KamaalLogger

private let logger = KamaalLogger(label: "SecretsJSON", failOnError: true)

struct Secrets: Codable {
    let apiKey: String?
    let apiURL: URL?

    enum CodingKeys: String, CodingKey {
        case apiKey = "api_key"
        case apiURL = "api_url"
    }
}

class SecretsJSON {
    private(set) var content: Secrets?

    private init() {
        do {
            self.content = try JSONFileUnpacker<Secrets>(filename: "Secrets", bundle: .module).content
        } catch {
            logger.error(label: "Failed to unpack json file", error: error)
        }
    }

    static let shared = SecretsJSON()
}
