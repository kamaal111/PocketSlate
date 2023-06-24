//
//  CloudPhrase.swift
//
//
//  Created by Kamaal M Farah on 24/06/2023.
//

import CloudKit
import Foundation
import KamaalLogger
import KamaalExtensions

private let logger = KamaalLogger(from: CloudPhrase.self, failOnError: true)

struct CloudPhrase: StorablePhrase {
    let id: UUID
    let kCreationDate: Date
    let updatedDate: Date
    private(set) var translations: [Locale: [String]]
    private var record: CKRecord?

    init(id: UUID, kCreationDate: Date, updatedDate: Date, translations: [Locale: [String]], record: CKRecord? = nil) {
        self.id = id
        self.kCreationDate = kCreationDate
        self.updatedDate = updatedDate
        self.translations = translations
        self.record = record
    }

    enum Errors: Error {
        case fetchFailure(context: Error)
    }

    func deleteTranslations(for _: [Locale]) async -> Result<Void, Errors> {
        fatalError()
    }

    static func list() async -> Result<[Self], Errors> {
        let records: [CKRecord]
        do {
            records = try await Skypiea.shared.list(ofType: recordType)
        } catch {
            return .failure(.fetchFailure(context: error))
        }
        let items = records
            .compactMap(Self.fromRecord(_:))
        assert(items.count == records.count)

        return .success(items)
    }

    static func create(translations _: [Locale: [String]]) async -> Result<Self, Errors> {
        fatalError()
    }

    static func listForLocale(_: [Locale]) async -> Result<[Self], Errors> {
        fatalError()
    }

    static func update(_: UUID, translations _: [Locale: [String]]) async -> Result<Self, Errors> {
        fatalError()
    }

    static func internalErrorToAppPhraseError(_: Errors) -> AppPhrase.Errors {
        fatalError()
    }

    static let source: PhraseStorageSources = .userDefaults

    static let recordType = "CloudPhrase"

    private static func fromRecord(_ record: CKRecord) -> CloudPhrase? {
        guard let id = (record["id"] as? NSString)?.uuid,
              let creationDate = record["kCreationDate"] as? Date,
              let updatedDate = record["updatedDate"] as? Date,
              let translationsNSData = record["translations"] as? NSData else { return nil }

        let translationsData = Data(referencing: translationsNSData)
        let translations = try? JSONDecoder().decode([Locale: [String]].self, from: translationsData)
        return CloudPhrase(
            id: id,
            kCreationDate: creationDate,
            updatedDate: updatedDate,
            translations: translations ?? [:],
            record: record
        )
    }
}
