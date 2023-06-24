//
//  Skypiea.swift
//
//
//  Created by Kamaal M Farah on 24/06/2023.
//

import CloudKit
import ICloutKit
import Foundation
import KamaalLogger

private let logger = KamaalLogger(from: Skypiea.self, failOnError: true)

class Skypiea {
    static let shared = Skypiea()

    private let iCloutKit = ICloutKit(
        containerID: "iCloud.com.io.kamaal.PocketSlate",
        databaseType: .private
    )

    private let subscriptionsWanted = [
        CloudPhrase.recordType,
    ]

    private(set) var subscriptions: [CKSubscription] = [] {
        didSet { logger.info("subscribed iCloud subscriptions; \(subscriptions)") }
    }

    func list(ofType objectType: String) async throws -> [CKRecord] {
        let predicate = NSPredicate(value: true)
        return try await filter(ofType: objectType, by: predicate)
    }

    func filter(ofType objectType: String, by predicate: NSPredicate) async throws -> [CKRecord] {
        let items = try await iCloutKit.fetch(ofType: objectType, by: predicate)
        var recordsMappedByID: [NSString: CKRecord] = [:]
        var recordsToDelete: [CKRecord] = []
        items.forEach { item in
            guard let id = item["id"] as? NSString else { return }

            if let recordToDelete = recordsMappedByID[id] {
                recordsToDelete = recordsToDelete.appended(recordToDelete)
            } else {
                recordsMappedByID[id] = item
            }
        }

        let deletedTasks = try await iCloutKit.deleteMultiple(recordsToDelete)
        if !deletedTasks.isEmpty {
            logger.info("deleted cloud records; \(deletedTasks)")
        }

        return recordsMappedByID.values.asArray()
    }
}
