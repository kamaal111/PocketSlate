//
//  Persistance.swift
//
//
//  Created by Kamaal M Farah on 17/09/2023.
//

import SwiftData
import Foundation

public class Persistance {
    public let dataContainer: ModelContainer

    private init() {
        let schema = Schema([AppPhrase.self, AppTranslation.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        do {
            self.dataContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to get data container; error='\(error)'")
        }
    }

    @MainActor
    public var dataContainerContext: ModelContext {
        dataContainer.mainContext
    }

    public static let shared = Persistance()
}
