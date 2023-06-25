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

protocol Cloudable {
    associatedtype Object: Cloudable

    var record: CKRecord? { get }

    static func fromRecord(_ record: CKRecord) -> Object?

    static var recordType: String { get }
}

enum CloudableErrors: Error {
    case iCloudDisabledByUser
}

extension Cloudable {
    func delete(onContext context: Skypiea) async throws {
        guard let record else {
            logger.error("failed to find a record to delete")
            return
        }

        try await context.delete(record)
    }

    func update(_ object: Object, on context: Skypiea) async throws -> Object? {
        try await Self.save(object, on: context)
    }

    static func create(_ object: Object, on context: Skypiea) async throws -> Object? {
        await findAndDeleteDuplicate(object, onContext: context)
        return try await save(object, on: context)
    }

    static func list(from context: Skypiea) async throws -> [Object] {
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

    static func find(by predicate: NSPredicate, from context: Skypiea) async throws -> Object? {
        try await filter(by: predicate, limit: 1, from: context)
            .first
    }

    static func filter(by predicate: NSPredicate,
                       limit: Int? = nil,
                       from context: Skypiea) async throws -> [Object] {
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

    private static func findAndDeleteDuplicate(_ object: Object, onContext context: Skypiea) async {
        guard let id = (object.record?["id"] as? NSString),
              let duplicateItem = try? await find(by: NSPredicate(format: "id == %@", id), from: context) else {
            return
        }

        do {
            try await duplicateItem.delete(onContext: context)
        } catch {
            logger.error(label: "failed to delete the duplicate item", error: error)
        }

        logger.warning("found duplicate item; \(duplicateItem)")
        assertionFailure()
    }

    private static func save(_ object: Object, on context: Skypiea) async throws -> Object? {
        guard let record = object.record else {
            logger.error("expected to save this object of \(object)")
            return nil
        }

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
