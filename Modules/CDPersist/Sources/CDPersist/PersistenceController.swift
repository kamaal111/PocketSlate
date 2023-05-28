//
//  PersistenceController.swift
//
//
//  Created by Kamaal Farah on 28/05/2023.
//

import CoreData
import Foundation
import KamaalCoreData
import KamaalExtensions

public class PersistenceController {
    private let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        let containerName = "PocketSlate"
        let persistentContainerBuilder = _PersistentContainerBuilder(
            entities: [
                CoreItem.entity,
            ],
            relationships: [],
            containerName: containerName,
            preview: inMemory
        )
        self.container = persistentContainerBuilder.make()

        if !inMemory, let defaultURL = container.persistentStoreDescriptions.first?.url {
            let defaultStore = NSPersistentStoreDescription(url: defaultURL)
            defaultStore.configuration = "Default"
            defaultStore.shouldMigrateStoreAutomatically = false
            defaultStore.shouldInferMappingModelAutomatically = true
        }

        container.viewContext.automaticallyMergesChangesFromParent = true

        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }

    public var context: NSManagedObjectContext {
        container.viewContext
    }

    func batchDelete(by ids: [UUID], request: NSFetchRequest<NSFetchRequestResult>) throws {
        request.predicate = NSPredicate(format: "id IN %@", ids.map(\.nsString))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(deleteRequest)
        try context.save()
    }

    public static let shared = PersistenceController()

    public static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        return result
    }()
}
