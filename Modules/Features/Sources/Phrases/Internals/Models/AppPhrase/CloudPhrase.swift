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

struct CloudPhrase: StorablePhrase, Cloudable {
    let id: UUID
    let kCreationDate: Date
    let updatedDate: Date
    private(set) var translations: [Locale: [String]]
    let record: CKRecord?

    init(id: UUID, kCreationDate: Date, updatedDate: Date, translations: [Locale: [String]], record: CKRecord? = nil) {
        self.id = id
        self.kCreationDate = kCreationDate
        self.updatedDate = updatedDate
        self.translations = translations
        self.record = record
    }

    enum Errors: Error {
        case fetchFailure(context: Error?)
        case creationFailure(context: Error?)
        case deletionFailure(context: Error?)
    }

    func deleteTranslations(for locales: [Locale]) async -> Result<Void, Errors> {
        let findPredicate = NSPredicate(format: "id == %@", id.nsString)
        let item: Self?
        do {
            item = try await Self.find(by: findPredicate, from: .shared)
        } catch {
            return .failure(.deletionFailure(context: error))
        }
        guard var item else { return .failure(.deletionFailure(context: nil)) }

        for locale in locales {
            item.translations[locale] = []
        }
        if item.translationsAreEmpty {
            do {
                try await item.delete(onContext: .shared)
            } catch {
                return .failure(.deletionFailure(context: error))
            }
            return .success(())
        }

        return await Self.update(id, translations: item.translations)
            .map { _ in () }
            .mapError { error in Errors.deletionFailure(context: error) }
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
        let createdItem: Self?
        do {
            createdItem = try await create(newItem, on: .shared)
        } catch {
            logger.error(label: "failed to create cloud phrase", error: error)
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

    static func update(_: UUID, translations _: [Locale: [String]]) async -> Result<Self, Errors> {
        fatalError()
    }

    static func internalErrorToAppPhraseError(_: Errors) -> AppPhrase.Errors {
        fatalError()
    }

    static let source: PhraseStorageSources = .cloud

    static let recordType = "CloudPhrase"

    static func fromRecord(_ record: CKRecord) -> CloudPhrase? {
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
