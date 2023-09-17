//
//  PersistentModel+extensions.swift
//
//
//  Created by Kamaal M Farah on 17/09/2023.
//

import SwiftData
import Foundation

extension PersistentModel {
    @MainActor
    static func filter<T: PersistentModel>(predicate: Predicate<T>) throws -> [T] {
        var translationFetch = FetchDescriptor<T>(predicate: predicate)
        translationFetch.includePendingChanges = true
        return try Persistance.shared.dataContainer.mainContext.fetch(translationFetch)
    }
}
