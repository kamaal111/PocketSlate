//
//  CloudTranslation.swift
//
//
//  Created by Kamaal M Farah on 24/07/2023.
//

import CloudKit
import Foundation
import CloudSyncing
import KamaalExtensions

struct CloudTranslation: Identifiable, Codable {
    let id: UUID
    let phraseID: UUID
    let locale: Locale
    let value: String
    let creationDate: Date
    private(set) var updatedDate: Date

    init(id: UUID, phraseID: UUID, locale: Locale, value: String, creationDate: Date, updatedDate: Date) {
        self.id = id
        self.phraseID = phraseID
        self.locale = locale
        self.value = value
        self.creationDate = creationDate
        self.updatedDate = updatedDate
        assert(Skypiea.shared.subscriptionsWanted.contains(Self.recordType))
    }
}

// MARK: Cloudable

extension CloudTranslation: Cloudable {
    static let recordType = "CloudTranslation"

    func toRecord() -> CKRecord {
        RecordKeys.allCases.reduce(CKRecord(recordType: Self.recordType)) { result, key in
            switch key {
            case .id:
                result[key] = id.nsString
            case .phraseID:
                result[key] = phraseID.nsString
            case .locale:
                result[key] = locale.identifier.nsString
            case .value:
                result[key] = value.nsString
            case .creationDate:
                result[key] = creationDate
            case .updatedDate:
                result[key] = updatedDate
            }
            return result
        }
    }

    static func fromRecord(_ record: CKRecord) -> CloudTranslation? {
        assert(RecordKeys.allCases.allSatisfy { key in record[key] != nil })
        guard let id = (record[.id] as? NSString)?.uuid else { return nil }
        guard let phraseID = (record[.phraseID] as? NSString)?.uuid else { return nil }
        guard let localeID = (record[.locale] as? NSString)?.string else { return nil }
        guard let value = (record[.value] as? NSString)?.string else { return nil }
        guard let creationDate = record[.creationDate] as? Date else { return nil }
        guard let updatedDate = record[.updatedDate] as? Date else { return nil }

        let locale = Locale(identifier: localeID)
        return CloudTranslation(
            id: id,
            phraseID: phraseID,
            locale: locale,
            value: value,
            creationDate: creationDate,
            updatedDate: updatedDate
        )
    }

    enum RecordKeys: String, CaseIterable {
        case id
        case phraseID
        case locale
        case value
        case creationDate = "kCreationDate"
        case updatedDate
    }
}

extension CKRecord {
    fileprivate subscript(key: CloudTranslation.RecordKeys) -> Any? {
        get { self[key.rawValue] }
        set { self[key.rawValue] = newValue as? CKRecordValue }
    }
}
