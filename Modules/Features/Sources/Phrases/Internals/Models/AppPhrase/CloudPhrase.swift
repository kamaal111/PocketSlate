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
    private(set) var updatedDate: Date
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
        case updateFailure(context: Error?)
    }

    func deleteTranslations(for locales: [Locale]) async -> Result<Self?, Errors> {
        var item: Self
        switch await fetchIfRecordIsEmpty() {
        case let .failure(failure):
            return .failure(.deletionFailure(context: failure))
        case let .success(success):
            item = success
        }

        for locale in locales {
            item.translations[locale] = []
        }
        if item.translationsAreEmpty {
            return await delete()
                .map { nil }
        }

        return await item.update(translations: item.translations)
            .map { success in success }
            .mapError { error in Errors.deletionFailure(context: error) }
    }

    func update(translations: [Locale: [String]]) async -> Result<Self, Errors> {
        var item: Self
        switch await fetchIfRecordIsEmpty() {
        case let .failure(failure):
            return .failure(.deletionFailure(context: failure))
        case let .success(success):
            item = success
        }

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

    static func internalErrorToAppPhraseError(_: Errors) -> AppPhrase.Errors {
        fatalError()
    }

    static func fromAppPhrase(_: AppPhrase) -> CloudPhrase {
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

    private func delete() async -> Result<Void, Errors> {
        var item: Self
        switch await fetchIfRecordIsEmpty() {
        case let .failure(failure):
            return .failure(.deletionFailure(context: failure))
        case let .success(success):
            item = success
        }

        do {
            try await item.delete(onContext: .shared)
        } catch {
            return .failure(.deletionFailure(context: error))
        }
        return .success(())
    }

    private func fetchIfRecordIsEmpty() async -> Result<Self, Errors> {
        if record != nil {
            return .success(self)
        }

        logger.info("fetching item with id \(id.uuidString), because record is empty")
        let item: Self?
        let predicate = NSPredicate(format: "id == %@", id.nsString)
        do {
            item = try await Self.find(by: predicate, from: .shared)
        } catch {
            return .failure(.fetchFailure(context: error))
        }
        guard let item else { return .failure(.fetchFailure(context: nil)) }

        return .success(item)
    }
}
