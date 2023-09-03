//
//  CloudTranslation.swift
//
//
//  Created by Kamaal M Farah on 02/09/2023.
//

import CloudKit
import Foundation
import CloudSyncing
import KamaalExtensions

struct CloudTranslation: Identifiable, Hashable {
    let record: CKRecord

    init(record: CKRecord) {
        self.record = record
        assert(Skypiea.shared.subscriptionsWanted.contains(Self.recordType))
    }

    var phraseReference: CKRecord.Reference {
        guard let reference = record["phrase"] as? CKRecord.Reference else {
            fatalError("Should have phrase referernce")
        }
        return reference
    }

    var locale: Locale {
        guard let identifier = record["localeID"] as? NSString else { fatalError("Should have locale identifier") }
        return Locale(identifier: identifier.string)
    }

    var value: String {
        guard let value = record["value"] as? NSString else { fatalError("Should have value") }
        return value.string
    }

    static func makeRecord(
        phraseReference: CKRecord.Reference,
        locale: Locale,
        value: String,
        recordName: String? = nil
    ) -> CKRecord {
        let record: CKRecord
        if let recordName {
            record = CKRecord(recordType: recordType, recordID: .init(recordName: recordName))
        } else {
            record = CKRecord(recordType: recordType)
        }
        return RecordKeys.allCases.reduce(record) { result, key in
            switch key {
            case .localeID: result[key.rawValue] = locale.identifier.nsString!
            case .phrase: result[key.rawValue] = phraseReference
            case .value: result[key.rawValue] = value.nsString!
            }
            return result
        }
    }
}

extension CloudTranslation: Cloudable {
    static let recordType = "CloudTranslation"

    static func fromRecord(_ record: CKRecord) -> Self? {
        CloudTranslation(record: record)
    }
}

private enum RecordKeys: String, CaseIterable {
    case phrase
    case localeID
    case value
}
