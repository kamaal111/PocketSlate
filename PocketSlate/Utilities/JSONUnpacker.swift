//
//  JSONUnpacker.swift
//  PocketSlate
//
//  Created by Kamaal Farah on 28/05/2023.

import Foundation
import KamaalLogger
import KamaalSettings

private let logger = KamaalLogger(label: "JSONUnpacker")

class AcknowledgementsJSON: JSONUnpacker<Acknowledgements> {
    override private init(filename: String, ofType fileType: String = "json") {
        super.init(filename: filename, ofType: fileType)
    }

    static let shared = AcknowledgementsJSON(filename: "Acknowledgements")
}

class JSONUnpacker<Content: Decodable> {
    var content: Content?

    init(filename: String, ofType fileType: String = "json") {
        guard let path = Bundle.main.path(forResource: filename, ofType: fileType) else {
            assertionFailure("json resources with name \(filename) not found")
            logger.warning("json resources with name \(filename) not found")
            return
        }
        let url = URL(fileURLWithPath: path)
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            logger.error(label: "failed to read json data with name \(filename)", error: error)
            assertionFailure("failed to read json data with name \(filename)")
            return
        }

        let content: Content
        do {
            content = try JSONDecoder().decode(Content.self, from: data)
        } catch {
            logger.error(label: "failed to decode json file with name \(filename)", error: error)
            assertionFailure("failed to decode json file with name \(filename)")
            return
        }

        self.content = content
    }
}
