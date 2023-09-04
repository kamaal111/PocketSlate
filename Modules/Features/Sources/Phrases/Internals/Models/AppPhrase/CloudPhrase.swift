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

struct CloudPhrase: Identifiable, Hashable {
    let record: CKRecord
    private let translationRecords: [CloudTranslation]

    init(record: CKRecord) {
        self.init(record: record, translations: [])
    }

    private init(record: CKRecord, translations: [CloudTranslation]) {
        self.record = record
        self.translationRecords = translations
        assert(Skypiea.shared.subscriptionsWanted.contains(Self.recordType))
    }

    var reference: CKRecord.Reference {
        CKRecord.Reference(record: record, action: .deleteSelf)
    }

    var translations: [Locale: String] {
        translationRecords
            .reduce([:]) { result, translation in result.merged(with: [translation.locale: translation.value]) }
    }
}

// MARK: Cloudable

extension CloudPhrase: Cloudable {
    static let recordType = "CloudPhrase"

    static func fromRecord(_ record: CKRecord) -> Self? {
        CloudPhrase(record: record)
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
        let translationsToDelete = translationRecords
            .filter { translation in locales.contains(translation.locale) }
            .map(\.record)
        let context: Skypiea = .shared
        do {
            try await context.batchDelete(translationsToDelete)
        } catch {
            return .failure(.deletionFailure(context: error))
        }

        let updatedTranslations = translationRecords
            .filter { translation in !locales.contains(translation.locale) }
        let updatedPhrase = CloudPhrase(record: record, translations: updatedTranslations)
        return .success(updatedPhrase)
    }

    func update(translations: [Locale: String]) async -> Result<Self, Errors> {
        let context: Skypiea = .shared
        let newTranslations = translations
            .map { locale, newTranslation in
                let existingTranslation = self.translationRecords.find(by: \.locale, is: locale)
                return CloudTranslation.makeRecord(
                    phraseReference: reference,
                    locale: locale,
                    value: newTranslation,
                    recordName: existingTranslation?.record.recordID.recordName
                )
            }
        let result: [CKRecord]
        do {
            result = try await context.batchSave(newTranslations)
        } catch {
            return .failure(.updateFailure(context: error))
        }

        let updatedTranslation = result
            .map { record in CloudTranslation(record: record) }
        let newPhrase = CloudPhrase(record: record, translations: updatedTranslation)
        return .success(newPhrase)
    }

    static func list() async -> Result<[CloudPhrase], Errors> {
        let context: Skypiea = .shared
        let items: [CloudPhrase]
        do {
            items = try await list(from: context)
        } catch {
            return .failure(.fetchFailure(context: error))
        }
        guard !items.isEmpty else { return .success(items) }

        let references = items.map(\.reference)
        let predicate = NSPredicate(format: "phrase in %@", references)
        let translations: [CloudTranslation]
        do {
            translations = try await CloudTranslation.filter(by: predicate, from: context)
        } catch {
            return .failure(.fetchFailure(context: error))
        }
        let translationsMappedByPhraseIDs = Dictionary(grouping: translations) { translation in
            let reference = translation.phraseReference
            let phrase = items.find(by: \.reference, is: reference)!
            return phrase.id
        }
        let phrasesWithTranslations = items
            .map { phrase in
                CloudPhrase(record: phrase.record, translations: translationsMappedByPhraseIDs[phrase.id] ?? [])
            }
        return .success(phrasesWithTranslations)
    }

    static func create(translations: [Locale: [String]]) async -> Result<Self, Errors> {
        let newItem = CKRecord(recordType: recordType)
        let reference = CKRecord.Reference(record: newItem, action: .deleteSelf)
        let translationRecords = translations
            .flatMap { translation in
                translation
                    .value
                    .filter { translationValue in
                        !translationValue.trimmingByWhitespacesAndNewLines.isEmpty
                    }
                    .map { translationValue in
                        CloudTranslation.makeRecord(
                            phraseReference: reference,
                            locale: translation.key,
                            value: translationValue
                        )
                    }
            }
        let context: Skypiea = .shared
        let savedRecords: [CKRecord]
        do {
            savedRecords = try await context.batchSave(translationRecords.appended(newItem))
        } catch {
            return .failure(.creationFailure(context: error))
        }

        let phraseRecord = savedRecords.find(by: \.recordType, is: recordType)!
        let savedTranslationRecords = savedRecords
            .filter { record in record.recordType == CloudTranslation.recordType }
            .map { record in CloudTranslation(record: record) }
        let newPhrase = CloudPhrase(record: phraseRecord, translations: savedTranslationRecords)

        return .success(newPhrase)
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
        case .fetchFailure: return .fetchFailure(context: error)
        case .creationFailure: return .creationFailure(context: error)
        case .deletionFailure: return .deletionFailure(context: error)
        case .updateFailure: return .updateFailure(context: error)
        }
    }

    static func fromAppPhrase(_ phrase: AppPhrase) -> CloudPhrase {
        let record = CKRecord(recordType: recordType, recordID: .init(recordName: phrase.id.uuidString.uppercased()))
        let translations = phrase.translations
            .map { locale, translation in
                let record = CloudTranslation.makeRecord(
                    phraseReference: CKRecord.Reference(
                        recordID: .init(recordName: phrase.id.nsString.uppercased), action: .deleteSelf
                    ),
                    locale: locale,
                    value: translation
                )
                return CloudTranslation(record: record)
            }
        return CloudPhrase(record: record, translations: translations)
    }

    static let source: PhraseStorageSources = .cloud
}
