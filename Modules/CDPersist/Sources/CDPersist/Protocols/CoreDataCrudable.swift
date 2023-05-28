//
//  CoreDataCrudable.swift
//
//
//  Created by Kamaal Farah on 28/05/2023.
//

import Models
import Foundation
import KamaalCoreData

protocol CoreDataCrudable: ManuallyManagedObject, Crudable, Identifiable { }

extension CoreDataCrudable {
    public func delete() throws {
        try delete(save: true)
    }

    public static func batchDelete(ids: [UUID], on controller: PersistenceController) throws {
        try controller.batchDelete(by: ids, request: fetchRequest())
    }

    public static func find(by id: UUID, from controller: PersistenceController) throws -> Self? {
        let predicate = NSPredicate(format: "id = %@", id.nsString)
        return try find(by: predicate, from: controller.context)
    }

    public static func list(from controller: PersistenceController) throws -> [Self] {
        try filter(by: NSPredicate(value: true), from: controller.context)
    }

    public static func filter(ids: [UUID], from controller: PersistenceController) throws -> [Self] {
        let predicate = NSPredicate(format: "id IN %@", ids.map(\.nsString))
        return try filter(by: predicate, from: controller.context)
    }
}
