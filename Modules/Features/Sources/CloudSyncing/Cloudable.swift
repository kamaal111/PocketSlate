//
//  Cloudable.swift
//
//
//  Created by Kamaal M Farah on 24/06/2023.
//

import CloudKit
import Foundation
import KamaalCloud
import KamaalLogger

private let logger = KamaalLogger(from: (any Cloudable).self, failOnError: true)

public protocol Cloudable: Identifiable, Hashable {
    var id: UUID { get }
    var record: CKRecord { get }
    static var recordType: String { get }
    static func fromRecord(_ record: CKRecord) -> Self?
}

public enum CloudableErrors: Error {
    case iCloudDisabledByUser
}

extension Cloudable {
    public var id: UUID {
        UUID(uuidString: record.recordID.recordName)!
    }

    public var updatedDate: Date {
        record.modificationDate ?? Date()
    }

    public var creationDate: Date {
        record.creationDate ?? Date()
    }

    public func delete(onContext context: Skypiea) async throws {
        try await context.delete(record)
    }

    public func update(_ updatedRecord: CKRecord, on context: Skypiea) async throws -> Self? {
        try await Self.save(updatedRecord, on: context)
    }

    public func update(on context: Skypiea) async throws -> Self? {
        try await update(record, on: context)
    }

    public static func create(_ record: CKRecord, on context: Skypiea) async throws -> Self? {
        try await save(record, on: context)
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
            items = try await context.filter(ofType: recordType, by: predicate, limit: limit)
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

    private static func save(_ record: CKRecord, on context: Skypiea) async throws -> Self? {
        let savedRecord = try await context.save(record)
        return Self.fromRecord(savedRecord)
    }

    private static func handleFetchErrors(_ error: Error) throws {
        if let accountErrors = error as? CloudAccountsModule.Errors {
            switch accountErrors {
            case .noAccount: throw CloudableErrors.iCloudDisabledByUser
            default: break
            }
        }
    }
}
