//
//  CoreItem.swift
//
//
//  Created by Kamaal Farah on 28/05/2023.
//

import Models
import CoreData
import Foundation
import KamaalCoreData
import KamaalExtensions

@objc(CoreItem)
public class CoreItem: NSManagedObject, ManuallyManagedObject, Identifiable, CoreDataCrudable {
    @NSManaged public var updateDate: Date
    @NSManaged public var kCreationDate: Date
    @NSManaged public var id: UUID

    public static let properties = baseProperties

    public static let _relationships: [_RelationshipConfiguration] = []

    public var asReturnType: Item {
        Item(id: id)
    }

    public func update(_ payload: Payload) throws -> CoreItem {
        let updatedItem = updateValues(payload)

        try managedObjectContext?.save()

        return updatedItem
    }

    public static func create(_ payload: Payload, from context: PersistenceController) throws -> CoreItem {
        try create(payload, from: context, save: true)
    }

    public static func create(_ payload: Payload,
                              from controller: PersistenceController,
                              save: Bool) throws -> CoreItem {
        let item = CoreItem(context: controller.context)
            .updateValues(payload)

        item.updateDate = Date()
        item.id = UUID()

        if save {
            try controller.context.save()
        }

        return item
    }

    func updateValues(_: Payload) -> CoreItem {
        updateDate = Date()

        return self
    }

    public struct Payload {
        public init() { }
    }
}
