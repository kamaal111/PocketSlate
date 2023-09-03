//
//  Skypiea.swift
//
//
//  Created by Kamaal M Farah on 24/06/2023.
//

import CloudKit
import Foundation
import KamaalCloud
import KamaalLogger
import KamaalExtensions

private let logger = KamaalLogger(from: Skypiea.self, failOnError: true)

public class Skypiea {
    public static let shared = Skypiea()

    private let cloud = KamaalCloud(
        containerID: "iCloud.com.\(Bundle.main.bundleIdentifier!)",
        databaseType: .private
    )

    public let subscriptionsWanted = [
        "CloudPhrase",
        "CloudTranslation",
    ]

    private var subscriptions: [CKSubscription] = [] {
        didSet { logger.info("subscribed iCloud subscriptions; \(subscriptions)") }
    }

    public func subscripeToAll() async throws {
        let fetchedSubscriptions = try await fetchAllSubcriptions()
        let fetchedSubscriptionsAsRecordTypes: [CKRecord.RecordType] = fetchedSubscriptions.compactMap {
            guard let query = $0 as? CKQuerySubscription else { return nil }
            return query.recordType
        }

        let subscriptionsToSubscribeTo = subscriptionsWanted.filter { !fetchedSubscriptionsAsRecordTypes.contains($0) }
        let subscribedSubsctiptions = try await cloud.subscriptions
            .subscribeToChanges(ofTypes: subscriptionsToSubscribeTo).get()
        subscriptions = fetchedSubscriptions + subscribedSubsctiptions
    }

    func save(_ record: CKRecord) async throws -> CKRecord {
        try await cloud.objects.save(record: record).get()
    }

    func list(ofType objectType: String) async throws -> [CKRecord] {
        let predicate = NSPredicate(value: true)
        return try await filter(ofType: objectType, by: predicate)
    }

    func filter(ofType objectType: String, by predicate: NSPredicate, limit: Int? = nil) async throws -> [CKRecord] {
        let items = try await cloud.objects.filter(ofType: objectType, by: predicate, limit: limit).get()
        let (_, nonDuplicatesRecords) = try await deleteDuplicateOrDefectedRecords(items)

        return nonDuplicatesRecords
    }

    @discardableResult
    func delete(_ record: CKRecord) async throws -> CKRecord.ID {
        try await cloud.objects.delete(record: record).get()
    }

    @discardableResult
    public func batchDelete(_ records: [CKRecord]) async throws -> [CKRecord.ID] {
        try await cloud.objects.delete(records: records).get()
    }

    public func batchSave(_ records: [CKRecord]) async throws -> [CKRecord] {
        try await cloud.objects.save(records: records).get()
    }

    private func deleteDuplicateOrDefectedRecords(_ records: [CKRecord]) async throws
        -> (deletedRecords: [CKRecord.ID], nonDuplicatesRecords: [CKRecord]) {
        var recordsMappedByRecordName: [String: CKRecord] = [:]
        var recordsToDelete: [CKRecord] = []
        records.forEach { item in
            let recordName = item.recordID.recordName
            if recordsMappedByRecordName[recordName] != nil {
                recordsToDelete = recordsToDelete.appended(item)
            } else {
                recordsMappedByRecordName[recordName] = item
            }
        }

        let deletedTasks = try await batchDelete(recordsToDelete)
        if !deletedTasks.isEmpty {
            logger.info("deleted cloud records; \(deletedTasks)")
        }

        return (deletedTasks, recordsMappedByRecordName.values.asArray())
    }

    private func fetchAllSubcriptions() async throws -> [CKSubscription] {
        try await cloud.subscriptions.fetchAllSubscriptions().get()
    }

    private func subscribeAll(toType objectType: String) async throws -> CKSubscription {
        logger.info("subscribing to all \(objectType) iCloud subscriptions")
        return try await cloud.subscriptions.subscribeToChanges(ofType: objectType).get()
    }
}
