//
//  JSONUnpacker.swift
//  PocketSlate
//
//  Created by Kamaal Farah on 28/05/2023.

import Foundation
import KamaalUtils
import KamaalLogger
import KamaalSettings

private let logger = KamaalLogger(label: "JSONUnpacker")

class AcknowledgementsJSON {
    private(set) var content: Acknowledgements?

    private init() {
        do {
            self.content = try JSONFileUnpacker<Acknowledgements>(filename: "Acknowledgements").content
        } catch {
            logger.error(label: "Failed to unpack json file", error: error)
        }
    }

    static let shared = AcknowledgementsJSON().content
}
