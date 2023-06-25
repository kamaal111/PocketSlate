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
import KamaalExtensions

private let logger = KamaalLogger(from: Skypiea.self, failOnError: true)

public class Skypiea {
    public static let shared = Skypiea()

    private let iCloutKit = ICloutKit(
        containerID: "iCloud.com.\(Bundle.main.bundleIdentifier!)",
        databaseType: .private
    )

    public let subscriptionsWanted = [
        "CloudPhrase",
    ]

    public private(set) var subscriptions: [CKSubscription] = [] {
        didSet { logger.info("subscribed iCloud subscriptions; \(subscriptions)") }
    }

    func save(_ record: CKRecord) async throws -> CKRecord? {
        try await iCloutKit.save(record)
    }

    func list(ofType objectType: String) async throws -> [CKRecord] {
        let predicate = NSPredicate(value: true)
        return try await filter(ofType: objectType, by: predicate)
    }

    func filter(ofType objectType: String, by predicate: NSPredicate) async throws -> [CKRecord] {
        let items = try await iCloutKit.fetch(ofType: objectType, by: predicate)
        let (_, nonDuplicatesRecords) = try await deleteDuplicateOrDefectedRecords(items)

        return nonDuplicatesRecords
    }

    func delete(_ record: CKRecord) async throws {
        _ = try await iCloutKit.delete(record)
    }

    @discardableResult
    func batchDelete(_ records: [CKRecord]) async throws -> [CKRecord] {
        try await iCloutKit.deleteMultiple(records)
    }

    private func deleteDuplicateOrDefectedRecords(_ records: [CKRecord]) async throws
        -> (deletedRecords: [CKRecord], nonDuplicatesRecords: [CKRecord]) {
        var recordsMappedByID: [NSString: CKRecord] = [:]
        var recordsToDelete: [CKRecord] = []
        records.forEach { item in
            if let id = item["id"] as? NSString {
                if let recordToDelete = recordsMappedByID[id] {
                    recordsToDelete = recordsToDelete.appended(recordToDelete)
                } else {
                    recordsMappedByID[id] = item
                }
                return
            }

            recordsToDelete = recordsToDelete.appended(item)
        }

        let deletedTasks = try await batchDelete(recordsToDelete)
        assert(deletedTasks.count == recordsToDelete.count)
        if !deletedTasks.isEmpty {
            logger.info("deleted cloud records; \(deletedTasks)")
        }

        return (deletedTasks, recordsMappedByID.values.asArray())
    }
}
