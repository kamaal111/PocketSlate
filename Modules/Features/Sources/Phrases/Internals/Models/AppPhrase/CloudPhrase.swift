//
//  CloudPhrase.swift
//
//
//  Created by Kamaal M Farah on 24/06/2023.
//

import CloudKit
import Foundation
import KamaalLogger
import CloudSyncing
import KamaalExtensions

private let logger = KamaalLogger(from: CloudPhrase.self, failOnError: true)

struct CloudPhrase {
    let id: UUID
    let kCreationDate: Date
    private(set) var updatedDate: Date
    private(set) var translations: [Locale: [String]]

    init(id: UUID, kCreationDate: Date, updatedDate: Date, translations: [Locale: [String]]) {
        self.id = id
        self.kCreationDate = kCreationDate
        self.updatedDate = updatedDate
        self.translations = translations
        assert(Skypiea.shared.subscriptionsWanted.contains(Self.recordType))
    }
}

// MARK: Cloudable

extension CloudPhrase: Cloudable {
    static let recordType = "CloudPhrase"

    func toRecord() -> CKRecord {
        RecordKeys.allCases.reduce(CKRecord(recordType: Self.recordType)) { result, key in
            switch key {
            case .id:
                result[key] = id.nsString
            case .creationDate:
                result[key] = kCreationDate
            case .updatedDate:
                result[key] = updatedDate
            case .translations:
                let translationsData: Data
                do {
                    translationsData = try JSONEncoder().encode(translations)
                } catch {
                    logger.error(label: "failed to encode translations", error: error)
                    return result
                }
                result[key] = NSData(data: translationsData)
            }

            return result
        }
    }

    static func fromRecord(_ record: CKRecord) -> Self? {
        assert(RecordKeys.allCases.allSatisfy { key in record[key] != nil })
        guard let id = (record[.id] as? NSString)?.uuid else { return nil }
        guard let creationDate = record[.creationDate] as? Date else { return nil }
        guard let updatedDate = record[.updatedDate] as? Date else { return nil }
        guard let translationsNSData = record[.translations] as? NSData else { return nil }

        let translationsData = Data(referencing: translationsNSData)
        let translations = try? JSONDecoder().decode([Locale: [String]].self, from: translationsData)
        return CloudPhrase(
            id: id,
            kCreationDate: creationDate,
            updatedDate: updatedDate,
            translations: translations ?? [:]
        )
    }

    enum RecordKeys: String, CaseIterable {
        case id
        case creationDate = "kCreationDate"
        case updatedDate
        case translations
    }
}

extension CKRecord {
    fileprivate subscript(key: CloudPhrase.RecordKeys) -> Any? {
        get { self[key.rawValue] }
        set { self[key.rawValue] = newValue as? CKRecordValue }
    }
}

// MARK: StorablePhrase

extension CloudPhrase: StorablePhrase {
    enum Errors: Error {
        case fetchFailure(context: Error?)
        case creationFailure(context: Error?)
        case deletionFailure(context: Error?)
        case updateFailure(context: Error?)
    }

    func deleteTranslations(for locales: [Locale]) async -> Result<Self?, Errors> {
        var item = self

        for locale in locales {
            item.translations[locale] = []
        }
        if item.translationsAreEmpty {
            return await delete()
                .map { nil }
        }

        return await item.update(translations: item.translations)
            .map { success in success }
            .mapError { error in .deletionFailure(context: error) }
    }

    func update(translations: [Locale: [String]]) async -> Result<Self, Errors> {
        var item = self
        item.translations = translations
        item.updatedDate = Date()

        let updatedItem: CloudPhrase?
        do {
            updatedItem = try await item.update(on: .shared)
        } catch {
            return .failure(.updateFailure(context: error))
        }
        guard let updatedItem else { return .failure(.updateFailure(context: nil)) }

        return .success(updatedItem)
    }

    static func list() async -> Result<[Self], Errors> {
        let items: [Self]
        do {
            items = try await list(from: .shared)
        } catch {
            return .failure(.fetchFailure(context: error))
        }

        return .success(items)
    }

    static func create(translations: [Locale: [String]]) async -> Result<Self, Errors> {
        let now = Date()
        let newItem = CloudPhrase(id: UUID(), kCreationDate: now, updatedDate: now, translations: translations)
            .toRecord()
        let createdItem: Self?
        do {
            createdItem = try await create(newItem, on: .shared)
        } catch {
            return .failure(.creationFailure(context: error))
        }

        guard let createdItem else { return .failure(.creationFailure(context: nil)) }

        return .success(createdItem)
    }

    static func listForLocale(_ locales: [Locale]) async -> Result<[Self], Errors> {
        await list()
            .map { success in
                success
                    .filter { phrase in
                        let translations = phrase.translations
                        guard !translations.isEmpty else { return false }

                        return !locales.allSatisfy { locale in translations[locale]?.isEmpty ?? true }
                    }
            }
    }

    static func internalErrorToAppPhraseError(_ error: Errors) -> AppPhrase.Errors {
        switch error {
        case .fetchFailure:
            return .fetchFailure(context: error)
        case .creationFailure:
            return .creationFailure(context: error)
        case .deletionFailure:
            return .deletionFailure(context: error)
        case .updateFailure:
            return .updateFailure(context: error)
        }
    }

    static func fromAppPhrase(_ phrase: AppPhrase) -> CloudPhrase {
        CloudPhrase(
            id: phrase.id,
            kCreationDate: phrase.creationDate,
            updatedDate: phrase.updatedDate,
            translations: phrase.translations
        )
    }

    static let source: PhraseStorageSources = .cloud
}

// MARK: Privates

extension CloudPhrase {
    private func delete() async -> Result<Void, Errors> {
        do {
            try await delete(onContext: .shared)
        } catch {
            return .failure(.deletionFailure(context: error))
        }
        return .success(())
    }
}
