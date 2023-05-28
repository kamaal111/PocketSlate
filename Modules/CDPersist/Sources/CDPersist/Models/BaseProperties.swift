//
//  BaseProperties.swift
//
//
//  Created by Kamaal Farah on 28/05/2023.
//

import KamaalCoreData

let baseProperties: [ManagedObjectPropertyConfiguration] = [
    ManagedObjectPropertyConfiguration(name: "updateDate", type: .date, isOptional: false),
    ManagedObjectPropertyConfiguration(name: "kCreationDate", type: .date, isOptional: false),
    ManagedObjectPropertyConfiguration(name: "id", type: .uuid, isOptional: false),
]
