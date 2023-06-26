//
//  Cloudable.swift
//
//
//  Created by Kamaal M Farah on 24/06/2023.
//

import CloudKit
import ICloutKit
import Foundation
import KamaalLogger

private let logger = KamaalLogger(from: (any Cloudable).self, failOnError: true)

public protocol Cloudable {
    func toRecord() -> CKRecord

    static func fromRecord(_ record: CKRecord) -> Self?

    static var recordType: String { get }
}

public enum CloudableErrors: Error {
    case iCloudDisabledByUser
}

extension Cloudable {
    public func delete(onContext context: Skypiea) async throws {
        try await context.delete(toRecord())
    }

    public func update(_ record: CKRecord, on context: Skypiea) async throws -> Self? {
        try await Self.save(record, on: context)
    }

    public func update(on context: Skypiea) async throws -> Self? {
        try await Self.save(toRecord(), on: context)
    }

    public static func create(_ record: CKRecord, on context: Skypiea) async throws -> Self? {
        await findAndDeleteDuplicate(record, onContext: context)
        return try await save(record, on: context)
    }

    public static func list(from context: Skypiea) async throws -> [Self] {
        let records: [CKRecord]

        do {
            records = try await context.list(ofType: recordType)
        } catch {
            try handleFetchErrors(error)
            throw error
        }

        let items = records
            .compactMap(fromRecord(_:))
        assert(items.count == records.count)
        return items
    }

    public static func find(by predicate: NSPredicate, from context: Skypiea) async throws -> Self? {
        try await filter(by: predicate, limit: 1, from: context)
            .first
    }

    public static func filter(by predicate: NSPredicate,
                              limit: Int? = nil,
                              from context: Skypiea) async throws -> [Self] {
        let items: [CKRecord]
        do {
            items = try await context.filter(ofType: recordType, by: predicate)
        } catch {
            try handleFetchErrors(error)
            throw error
        }

        let decodedItems = items
            .compactMap(fromRecord(_:))

        if let limit {
            if decodedItems.count < limit {
                return decodedItems
                    .asArray()
            }

            return decodedItems
                .prefix(upTo: limit)
                .asArray()
        }

        return decodedItems
    }

    private static func findAndDeleteDuplicate(_ record: CKRecord, onContext context: Skypiea) async {
        guard let id = (record["id"] as? NSString) else { return }

        let filterPredicate = NSPredicate(format: "id == %@", id)
        guard let duplicateItems = try? await filter(by: filterPredicate, from: context) else { return }
        guard !duplicateItems.isEmpty else { return }

        logger.warning("found duplicate items; \(duplicateItems)")
        let items = duplicateItems.map { item in item.toRecord() }
        do {
            try await context.batchDelete(items)
        } catch {
            logger.error(label: "failed to delete the duplicate item", error: error)
        }

        logger.warning("deleted duplicate items; \(items)")
        assertionFailure()
    }

    private static func save(_ record: CKRecord, on context: Skypiea) async throws -> Self? {
        guard let savedRecord = try await context.save(record) else { return nil }

        return Self.fromRecord(savedRecord)
    }

    private static func handleFetchErrors(_ error: Error) throws {
        if let accountErrors = error as? ICloutKit.AccountErrors {
            switch accountErrors {
            case .accountStatusNoAccount:
                throw CloudableErrors.iCloudDisabledByUser
            default:
                break
            }
        }
    }
}
